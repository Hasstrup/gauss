# frozen_string_literal: true

require 'csv'
require 'gauss/context'

module Gauss
  # Gauss::Vendor main actor for loading and fetching products
  class Vendor
    attr_reader :changes_path, :products_path, :context

    def initialize(products_path:, changes_path:)
      @products_path = products_path
      @changes_path = changes_path
      @context = Gauss::Context.new
    end

    def self.load(products_path:, changes_path:)
      vendor = new(products_path: products_path, changes_path: changes_path)
      vendor.create_records
      vendor
    end

    def create_records
      load_products
      load_changes
    end

    def reload(_args)
      create_records
      context.succeed(message: Gauss::Messages::LOAD_SUCCESS) if context.success

      context.message
    end

    private

    def store
      @store ||= Gauss::Store.new
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
        next store.add(key: klass.store_key, entry: record) if record.valid?

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
  end
end
