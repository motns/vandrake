module Vandrake
  # Used to run a validation on one or more attributes of a {Vandrake::Model} instance,
  # using a specific {Vandrake::Validator} instance.
  # Validations normally form part of a {Vandrake::ValidationChain}, but can also be used on their own.
  #
  # @!attribute [r] validator_class
  #   @return [Vandrake::Validator] A reference to the Validator class to validate with
  #
  # @!attribute [r] attributes
  #   @return [Array] A list of model attributes that will be used as the input for the Validator
  #
  class Validation

    attr :validator, :attributes


    # @overload initialize(validator, *attributes, params = {})
    #   Create Validation for given attribute with validator
    #   @param [Symbol] validator The name of the Validator class to use
    #   @param [Symbol, String] *attributes The name of one or more attributes to run the validation on
    #   @param [Hash] params A set of parameters to pass to the validator
    #
    # @raise [ArgumentError] If the validator name is not a Symbol
    # @raise [ArgumentError] If the validator in question is not recognised
    # @raise [ArgumentError] If one of the attribute names is not a Symbol
    #
    def initialize(validator, *args)
      raise ArgumentError, "Validator name should be provided as a Symbol, #{validator.class.name} given" unless validator.respond_to?(:to_sym)
      @attributes, params = Vandrake::extract_params(*args)

      validator_class = Vandrake::Validator.get_class(validator)
      raise ArgumentError, "Unknown validator: #{validator}" if validator_class.nil?

      @validator = validator_class.new(params)

      @attributes.map! do |attribute|
        raise ArgumentError, "Attribute name has to be a Symbol, #{attribute.class.name} given" unless attribute.respond_to?(:to_sym)
        attribute.to_sym
      end
    end


    # Runs the defined validation. It reads out the selected attribute(s) using
    # {Vandrake::Model#read_attribute}, and passes it to the {Vandrake::Validator}
    # along with any parameters.
    # If the validation fails, it appends a new entry to the {Vandrake::FailedValidators}
    # of this Model instance.
    #
    # @param [Vandrake::Model] document The Model instance we're validating
    #
    # @return [Boolean] True on success, False on failure
    #
    def run(document)
      values = @attributes.collect do |a|
        if @validator.class.raw? then document.read_attribute_before_type_cast(a)
        else document.read_attribute(a)
        end
      end

      if @validator.validate(*values)
        true
      else
        document.failed_validators.add(
          @attributes,
          @validator.class.validator_name,
          @validator.last_error,
          @validator.last_error_code
        )
        false
      end
    end
  end
end