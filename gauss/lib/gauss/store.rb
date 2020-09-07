# frozen_string_literal: true

require 'csv'

module Gauss
  class Vendor
    attr_reader :changes, :items, :changes_path, :items_path

    def initialize(items_path:, changes_path:)
      @items_path = items
      @changes_path = changes
    end

    private

    def load_items
      # the goal here will be to load those items from the path and return
    end
  end
end
