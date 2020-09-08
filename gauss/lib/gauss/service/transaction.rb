# frozen_string_literal: true

require 'pry'
require 'gauss/error'
require 'gauss/messages'

module Gauss
  module Service
    # Gauss::Service::Transaction
    class Transaction
      attr_reader :amount, :store, :context, :record, :quantity
      def initialize(amount:, store:, context:, record:, quantity:)
        @store = store
        @record = record
        @context = context
        @amount = amount.to_f
        @quantity = quantity.to_f
      end

      def perform
        safely_execute do
          unless amount_sufficient?
            return context.fail!(error: error_klass.new(Gauss::Messages::INSUFFICIENT_FUNDS))
          end
          unless amount_changeable?
            return context.fail!(error: error_klass.new(Gauss::Messages::NOT_CHANGEABLE))
          end

          changes = issue_changes.dig(:changes)
          update_count(records: [{ name: record.name, count: quantity }], klass: record.class, accessor: :name)
          update_count(records: changes, klass: Gauss::Change, accessor: :amount)

          context.payload!(payload: changes)
        end
      end

      private

      attr_reader :records, :store_changes

      def amount_changeable?
        total_change = store.records(store_key: Gauss::Change.store_key).inject(0) do |sum, line_item|
          sum + (line_item.dig(:count) * line_item.dig(:amount).to_f.round(2))
        end
        diff < (total_change * 100)
      end

      def amount_sufficient?
        amount.round(2) > (record.amount.to_f.round(2) * quantity.to_f.round(2))
      end

      def issue_changes
        changes.each_with_object(remainder: diff, changes: []) do |change, sum|
          next if sum[:remainder].zero?

          quotient = (sum[:remainder] / change.dig(:value)).to_i
          quotient = change.dig(:count) if quotient > change.dig(:count)
          sum[:remainder] = sum[:remainder] - (change.dig(:value) * quotient)
          unless quotient.zero?
            sum[:changes] << { count: quotient, amount: change.dig(:original_value) }
          end
        end
      end

      def snapshot_db
        @records = store.records(store_key: record.class.store_key)
        @store_changes = store.records(store_key: Gauss::Change.store_key)
      end

      def rollback_db
        store.load(key: record.class.store_key, entries: records)
        store.load(key: Gauss::Change.store_key, entriies: store_changes)
      end

      def update_count(records:, klass:, accessor:)
        records.each do |record|
          args = { key: record[accessor], store_key: klass.store_key, attribute: accessor }
          current_item = store.fetch(**args)
          current_item[:count] = current_item[:count] - record[:count]
          store.update(**args.merge(changes: current_item))
        end
      end

      def diff
        @diff ||= (amount.round(2) - (record.amount.to_f.round(2) * quantity)) * 100
      end

      def changes
        @changes ||= begin
          changes_available = store.records(store_key: Gauss::Change.store_key)
          target_changes = changes_available.map do |change|
            amount = change.dig(:amount)
            currency = amount[amount.length - 1]
            value = currency == '£' ? amount.chomp(currency).to_i * 100 : amount.chomp(currency).to_i
            next nil if change.dig(:count).zero? || value > diff

            { original_value: amount, value: value.to_f.round(2), count: change.dig(:count) }
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
