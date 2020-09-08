# frozen_string_literal: true

module Gauss
  class Error < StandardError; end
  class LoadError < Error
    attr_reader :errors
    def initialize(errors)
      @errors = errors
    end

    def message
      JSON.stringify(errors)
    end
  end

  class TransactionError < Error
  end
end
