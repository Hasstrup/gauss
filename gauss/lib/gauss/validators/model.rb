# frozen_string_literal: true

module Gauss
  module Validators
    module Model
      def self.included(klass)
        class << klass
          alias_method :__new, :new

          def new(*args)
            model = __new(*args)
            model.run_validations!
          end

          def validates(attr_name, **options)
            # TODO: { Use a model/OStruct instead of hash}
            validations.push(options.merge(name: attr_name))
          end

          def errors
            @errors ||= {}
          end

          private

          def validations
            @validations ||= []
          end

          def validate_presence(attribute:, _value: nil)
            attribute.present?
          end

          def validate_type(attribute:, value:)
            attribute.is_a?(value)
          end

          def validate_min(attribute:, value:)
            attribute >= value
          end

          def validate_max(attribute:, value:)
            attribute <= value
          end
        end
      end

      def run_validations!
        self.class.validations.each do |validator|
          validate(attribute: validator.dig(:name),
                   value: send(validator.dig(:name)),
                   validation_hash: validator.except(:name))
        end
      end

      def valid?
        errors.empty?
      end

      def validate(attribute:, value:, validation_hash:)
        validation_hash.each do |key, hash_value|
          unless self.class.send("validate_#{key}".to_sym,
                                 attribute: hash_value,
                                 value: value)
            message = const_get("Gauss::Validators::Messages::#{key.upcase}".to_sym)
            errors[attribute] = [*(errors[attribute] || []), message]
          end
        end
      end
    end
  end
end
