# frozen_string_literal: true
require 'gauss/validators/messages'

module Gauss
  module Validators
    module Model
      def self.included(klass)
        class << klass
          alias_method :__new, :new

          def new(*args)
            model = __new(*args)
            model.run_validations!

            model
          end

          def validates(attr_name, **options)
            validations.push(options.merge(name: attr_name))
          end

          def errors
            @errors ||= {}
          end

          def validations
            @validations ||= []
          end

          private

          def validate_presence(attribute:, value: nil)
            !attribute.nil?
          end

          def validate_type(attribute:, value:)
            attribute.is_a?(value)
          end

          def validate_min(attribute:, value:)
            attribute.to_f >= value
          end

          def validate_max(attribute:, value:)
            attribute.to_f <= value
          end

          def validate_in(attribute:, value:)
            value.include?(attribute)
          end
        end
      end

      def run_validations!
        self.class.validations.each do |validator|
          validate(attribute: validator.dig(:name),
                   value: send(validator.dig(:name)),
                   validation_hash: validator.slice(:type,
                                                    :presence,
                                                    :min,
                                                    :max).compact)
        end
      end

      def errors
        self.class.errors
      end

      def valid?
        errors.empty?
      end

      def validate(attribute:, value:, validation_hash:)
        validation_hash.each do |key, hash_value|
          next if self.class.send("validate_#{key}".to_sym,
                                  attribute: value,
                                  value: hash_value)

          message = self.class.const_get("Gauss::Validators::Messages::#{key.upcase}")
          errors[attribute] = [*(errors[attribute] || []), "#{message}: #{hash_value}"]
        end
      end
    end
  end
end
