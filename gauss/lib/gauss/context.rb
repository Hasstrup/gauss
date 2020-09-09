# frozen_string_literal: true

module Gauss
  # Gauss::Context holds errors, payload and messages of service ops
  class Context
    attr_reader :success, :errors, :messages, :payload

    def initialize
      @success = true
      @errors = []
      @messages = []
    end

    def fail!(error:)
      @success = false
      @errors = [error]

      message
    end

    def succeed(message:)
      @errors = []
      @success = true
      @messages = [message]

      message
    end

    def payload!(payload:)
      @errors = []
      @payload = payload
    end

    def message
      success ? messages.join(', ') : errors.map(&:message).join(', ')
    end
  end
end
