# frozen_string_literal: true

module Gauss
  # Gauss::Model bunch of methods for data access objects
  class Model
    include Gauss::Validators::Model
    attr_reader :id
    def initialize(attributes)
      @id = SecureRandom.uuid
      attributes.each do |key, value|
        instance_variable_set(key, value)
      end
    end

    def self.store_key
      "#{self.class.name.downcase}s"
    end
  end
end
