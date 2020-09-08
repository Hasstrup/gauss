# frozen_string_literal: true
require 'gauss/validators/model'

module Gauss
  # Gauss::Model bunch of methods for data access objects
  class Model
    include Gauss::Validators::Model
    attr_reader :id

    class << self
      attr_reader :fields

      def self.store_key
        "#{self.class.name.downcase}s"
      end

      def attributes(*attribute_list)
        @fields = attribute_list
        attr_reader(*fields)
      end
    end

    def initialize(attributes)
      @id = SecureRandom.uuid
      attributes.each do |key, value|
        instance_variable_set(key, value)
      end
    end
  end
end
