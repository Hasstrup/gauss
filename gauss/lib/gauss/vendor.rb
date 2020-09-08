# frozen_string_literal: true
require 'csv'

module Gauss
  # Gauss::Vendor main actor for loading and fetching products
  class Vendor
    attr_reader :changes_path, :products_path

    def initialize(products_path:, changes_path:)
      @products_path = products_path
      @changes_path = changes_path
    end

    def self.load(products_path:, changes_path:)
      vendor = new(products_path: products_path, changes_path: changes_path)
      vendor.create_records
      vendor
    end

    def create_records
      load_products
      load_changes

      raise Gauss::LoadError, load_errors if load_errors.any?
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
      CSV.read(path).drop(0).each_with_index do |row, index|
        record = klass.new(*attributes_for(klass: klass, row: row))
        next store.add(key: klass.store_key, entry: record) if record.valid?

        load_errors.push(registry: klass.store_key,
                         position: index,
                         errors: record.errors)
      end
    end

    def load_errors
      @load_errors ||= []
    end

    def attributes_for(klass:, row:)
      klass.fields.each_with_index.reduce({}) do |hash, (field, i)|
        hash[field] = row[i]
      end
    end
  end
end
