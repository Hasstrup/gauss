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

    def fetch(key:)
      if block_given?
        yield store[key]
      else
        store[key]
      end
    end
  end
end
