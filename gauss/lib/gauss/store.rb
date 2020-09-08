# frozen_string_literal: true

module Gauss
  # Gauss::Store -> store for products, changes in the future could wrap redis
  class Store
    attr_reader :store

    def initialize
      @store = {}
    end

    def load(key:, entries:)
      store[key] = entries
    end

    def add(key:, entry:)
      items = store.fetch(key, [])
      items.push(entry)
      store[key] = items
    end

    def fetch(key:, store_key:, attribute: :name)
      result = store.dig(store_key)&.find do |record|
        record.dig(attribute) == key
      end
      yield result if block_given?

      result
    end

    def update(key:, store_key:, changes:, attribute:)
      record = fetch(key: key, store_key: store_key, attribute: attribute)
      index = store[store_key].index(record)
      store[store_key][index] = record.merge(changes)
    end

    def records(store_key:)
      store.dig(store_key)
    end

    def purge
      @store = {}
    end
  end
end
