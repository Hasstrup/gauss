# frozen_string_literal: true

require 'gauss/validators/model'
require 'securerandom'

module Gauss
  # Gauss::Model bunch of methods for data access objects
  class Model
    include Gauss::Validators::Model
    attr_reader :id

    class << self
      attr_reader :fields

      def store_key
        "#{self.class.name.downcase}s"
      end

      def attributes(*attribute_list)
        @fields = attribute_list
        attr_reader(*fields)
      end
    end

    def initialize(*attributes)
      @id = SecureRandom.uuid
      attributes.each do |key, value|
        type = self.class.validations.find { |validator| validator.dig(:name) == key }&.dig(:type)
        instance_variable_set("@#{key}", send(type.to_s, value))
      end
    end
  end
end
