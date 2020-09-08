# frozen_string_literal: true

require 'gauss/error'
require 'gauss/messages'

module Gauss
  module Service
    # Gauss::Service::Transaction
    class Transaction
      attr_reader :amount, :store, :context
      def initialize(amount:, store:, context:, record:)
        @amount = amount
        @store = store
        @record = record
        @context = context
      end

      def perform
        safely_execute do
          unless amount_sufficient?
            return context.fail!(error: error_klass.new(Gauss::Messages::INSUFFICIENT_FUNDS))
          end
          unless amount_changeable?
            return context.fail!(error: error_klass.new(Gauss::Messages::NOT_CHANGEABLE))
          end

          context.payload!(payload: issue_changes)
        end
      end

      private

      attr_reader :records, :changes

      def amount_changeable?
        total_change = store.records(store_key: Gauss::Change.store_key).inject(0) do |sum, line_item|
          sum + (line_item.count * line_item.amount.to_f.round(2))
        end
        diff < (total_change * 100)
      end

      def amount_sufficient?
        amount.to_f.round(2) > record.amount.to_f.round(2)
      end

      def issue_changes
        changes.each_with_object(remainder: diff, changes: []) do |change, sum|
          quotient = sum[:remainder] / change.dig(:value)
          quotient = change.dig(:count) if quotient > change.dig(:count)

          remainder = sum[:remainder] - (change.dig(:value) * quotient)
          sum[:remainder] = remainder
          sum[:changes] = [*sum[:changes], { quotient: quotient, change: change.dig(:amount) }]
        end
      end

      def snapshot_db
        @records = store.records(store_key: record.class.store_key)
        @changes = store.records(store_key: Gauss::Change.store_key)
      end

      def rollback_db
        store.load(key: record.class.store_key, entries: records)
        store.load(key: Gauss::Change.store_key, entriies: changes)
      end

      def updae_change_count; end

      def update_product_count; end

      def diff
        @diff ||= (amount.to_f.round(2) - record.amount.to_f.round(2)) * 100
      end

      def changes
        @changes ||= begin
          changes_available = store.records(store_key: Gauss::Change.store_key)
          target_changes = changes_available.map do |change|
            currency = change[change.length - 1]
            value = currency == '£' ? change.chomp(currency).to_i * 100 : change.chomp(currency).to_i
            return nil if change.dig(:count).zero? || value > diff

            { original_value: change, value: value.to_f.round(2), count: change.dig(:count) }
          end

          target_changes.compact.sort_by { |change| change.dig(:value) }.reverse!
        end
      end

      def safely_execute(&block)
        snapshot_db
        block.call
      rescue Gauss::Error => e
        rollback_db
        context.fail!(error: error_klass.new(e.message))
      end

      def error_klass
        Gauss::TransactionError
      end
    end
  end
end
