# frozen_string_literal: true

require 'csv'

module Gauss
 # Gauss::Vendor main actor for loading and fetching products
  class Vendor
    attr_reader :changes_path, :items_path

    def initialize(items_path:, changes_path:)
      @items_path = items
      @changes_path = changes
    end

    def self.load(items_path:, changes_path:)
      new(items_path: items_path, changes_path: changes).load
    end

    def create_records
      load_products
      load_changes

      raise(Gauss::LoadError.new(load_errors).message) if load_errors.any?
    end

    private

    def store
      @store ||= Gauss::Store.new
    end

    def load_products
      load(klass: Gauss::Product, path: items_path)
    end

    def load_changes
      load(klass: Gauss::Change, path: changes_path)
    end

    def load(klass:, path:)
      CSV.read(path).drop(0).each_with_index do |row, index|
        record = klass.new(name: row[0], description: [1], amount: row[2])
        next store.add(key: klass.store_key, entry: record) if record.valid?

        load_errors.push(registry: klass.store_key,
                         position: index, 
                         errors: record.errors)
      end
    end

    def load_errors
      @load_errors ||= []
    end
  end
end
