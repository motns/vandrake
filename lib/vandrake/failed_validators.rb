module Vandrake
  # Used to store detailed information on the validation failures for a {Vandrake::Model} instance,
  # including validation errors for embedded documents as well.
  # Validation failures will be added by {Vandrake::Validation} items when the given validator
  # fails.
  #
  # Validation failures are stored in a hash of this format:
  #
  #   {
  #     :attribute => {
  #       :attribute_name => [
  #         {
  #           :validator => :Presence,
  #           :error_code => :missing,
  #           :message => "must be provided"
  #         }
  #       ],
  #     },
  #     :model => [
  #       {
  #         :validator => :ValueMatch,
  #         :attributes => [:attribute1, :attribute2],
  #         :error_code => :no_match,
  #         :message => "must be the same"
  #       }
  #     ]
  #   }
  #
  # Simple validation failures for individual attributes are stores under the attribute name,
  # whereas complex validators (which take multiple values), will be stored under :model
  class FailedValidators
    # Creates an empty hash for storing validation failures
    def initialize
      @failed_validators = {}
    end


    # Record a new validation failure. Depending on the number of entries provided
    # under attributes, this will either be added under the attribute name, or under
    # :model if multiple attributes were involved.
    #
    # @param [Array] attributes The list of attributes that failed validation
    # @param [String, Symbol] validator_name The name of the {Vandrake::Validator} that failed validation
    # @param [String] message The error message
    # @param [Symbol] error_code The specific error code of this failure
    #
    # @return [void]
    def add(attributes, validator_name, message, error_code = nil)
      attributes = attributes.collect { |a| a.to_sym }

      # This is a Model-wide (multi-field) validator
      if attributes.size > 1
        @failed_validators[:model] ||= []

        @failed_validators[:model] << {
          :validator => validator_name,
          :attributes => attributes, # this is mostly for reflection/debugging
          :error_code => error_code,
          :message => message
        }
      else
        attribute = attributes[0]

        @failed_validators[:attribute] ||= {}
        @failed_validators[:attribute][attribute] ||= []

        @failed_validators[:attribute][attribute] << {
          :validator => validator_name,
          :error_code => error_code,
          :message => message
        }
      end
    end


    # Used to include the failed validators from a single embedded document, contained
    # in the current Model.
    #
    # @param [Symbol] name The name under which the other Model is embedded
    # @param [Vandrake::FailedValidators] failed_validators The failed validator from the embedded Model
    # @return [void]
    # def include_embedded_model(name, failed_validators)
    #   return if failed_validators.list.empty?
    #   @failed_validators[:embedded_model] ||= {}
    #   @failed_validators[:embedded_model][name.to_sym] = failed_validators.list
    # end


    # Clear the list of failed validators
    #
    # @return [void]
    def clear
      @failed_validators = {}
    end


    # Return hash with failed validators
    #
    # @return [Hash]
    def list
      @failed_validators
    end
  end
end