# frozen_string_literal: true

require 'gauss/messages'

module Gauss
  class Error < StandardError; end
  class TransactionError < Error; end
  class StoreError < Error
    class RecordNotFound < StoreError
      def message
        Gauss::Messages::RECORD_NOT_FOUND
      end
    end
  end
end
