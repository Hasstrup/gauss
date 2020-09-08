# frozen_string_literal: true

module Gauss
  class Context
    attr_reader :success, :errors, :messages, :payload

    def initialize
      @success = true
      @errors = []
      @messages = []
    end

    def fail!(error:)
      @success = false
      errors.push(error)

      message
    end

    def succeed(message:)
      @errors = []
      messages.push(message)

      message
    end

    def payload!(payload:)
      @payload = payload
    end

    def message
      success ? messages.join(', ') : errors.map(&:message)
    end
  end
end