# frozen_string_literal: true

require 'csv'
require 'gauss/context'
require 'gauss/messages'
require 'gauss/service/transaction'

module Gauss
  # Gauss::Vendor main actor for loading and fetching products
  class Vendor
    attr_reader :changes_path, :products_path, :context, :product, :quantity

    def initialize(products_path:, changes_path:)
      @products_path = products_path
      @changes_path = changes_path
      @context = Gauss::Context.new
    end

    def reload(_args)
      store.purge
      create_records
      context.succeed(message: Gauss::Messages::LOAD_SUCCESS) if context.success

      context.message
    end

    def inventory(_)
      store.store
    end

    def fetch_product(name:, quantity:)
      store.fetch(key: name, store_key: Gauss::Product.store_key) do |record|
        unless record
          context.fail!(error: Gauss::Error.new(Gauss::Messages::RECORD_NOT_FOUND))
          return context.message
        end

        @product = Gauss::Product.new(*record)
        @quantity = quantity
        if product.count < quantity.to_i
          context.fail!(error: Gauss::Error.new("I only have #{product.count} left"))
        else
          price = (quantity.to_f * product.amount).round(2)
          context.succeed(message: "That would cost you £#{price}, Please enter your money")
        end
      end

      context.message
    end

    def process_transaction(amount:)
      if product
        valid_amount = amount.dup
        valid_amount.chomp('£')
        args = { amount: valid_amount, store: store, record: product, quantity: quantity, context: context }
        Gauss::Service::Transaction.new(**args).perform
      else
        context.fail!(error: Gauss::Error.new(Gauss::Messages::NO_PRODUCT))
      end

      context.errors.any? ? context.message : humanize_change_payload(changes: context.payload)
    end

    private

    def store
      @store ||= Gauss::Store.new
    end

    def create_records
      load_products
      load_changes
    end

    def load_products
      load(klass: Gauss::Product, path: products_path)
    end

    def load_changes
      load(klass: Gauss::Change, path: changes_path)
    end

    def load(klass:, path:)
      CSV.read(path).drop(1).each_with_index do |row, index|
        record = klass.new(*attributes_for(klass: klass, row: row))
        if record.valid?
          next store.add(key: klass.store_key, entry: record.humanize)
        end

        raise Gauss::Error, "#{klass.store_key} failed, errors: #{record.errors} at position: #{index}"
      end
    rescue ::CSV::MalformedCSVError, Gauss::Error => e
      context.fail!(error: e)
    end

    def attributes_for(klass:, row:)
      klass.fields.each_with_index.each_with_object({}) do |(field, i), hash|
        hash[field] = row[i]
      end
    end

    def humanize_change_payload(changes:)
      subtotal = lambda do |change|
        unit = change.dig(:amount)[-1..-1]
        "#{change.dig(:count).to_f * change.dig(:amount).to_f}#{unit}"
      end
      changes.reduce(Gauss::Messages::CHANGE_INFO) do |str, change|
        <<-STR
          #{str}\n
          amount: #{change.dig(:amount)}, count: #{change.dig(:count)}, sub: #{subtotal.call(change)}
        STR
      end
    end
  end
end
