module Vandrake
  # Validator instances are used to validate a single value (or set of values),
  # and provide additional feedback in the form of error messages and codes upon
  # failure. Certain validators (like Length) also require additional parameters
  # to configure their behaviour upon initialization (like setting the required :length constraint).
  #
  # Each validator has a pre-defined number of inputs. "Simple" validators (like {Vandrake::Validator::Length})
  # take a single value, whereas "complex" validators (like {Vandrake::Validator::ValueMatch}) take
  # two or more.
  #
  # When a Validator fails, it sets *last_error* and *last_error_code*
  # on the Validator instance to reflect the exact nature of the failure. This value
  # is reset every time the Validator is run, and only stores the details for the most
  # recent failure.
  module Validator

    # Returns a hash that maps Validator names (Symbols) to the actual Validator classes
    #
    # @return [Hash]
    def self.type_registry
      @type_registry ||= {}
    end


    # Returns the Validator class for the given type identifier
    #
    # @param [Symbol] type The name of the Validator
    #
    # @return [Class, nil] Returns the Type class if found, nil otherwise
    def self.get_class(type)
      return Validator.type_registry[type.to_sym] if type.respond_to?(:to_sym)
      return nil
    end


    # The class that every Validator inherits from. Its main purpose is to create a registry
    # of Validator classes, so we can use short names (Symbols) when referencing them.
    #
    # It also has a set of methods for managing the error codes and messages
    # emitted by the Validator classes.
    class Base

      attr :params, :last_error, :last_error_code

      # Get the number of arguments this Validator takes. Defaults to 1
      # @return [Fixnum]
      def self.inputs; @inputs ||= 1 end


      # Whether this Validator operates on the non-type-cast (raw) attribute. Defaults to False.
      # Defaults to False.
      # @return [Boolean]
      def self.raw?; @is_raw ||= false end


      # Returns the error codes and messages for this Validator in the following format:
      #
      #   {
      #      :error_code1 => :error_message1,
      #      :error_code2 => :error_message2
      #   }
      #
      # @return [Hash]
      def self.error_codes; @error_codes ||= {} end


      # Used to add Type classes to the central registry
      #
      # @param [Class] descendant
      def self.inherited(descendant)
        id = descendant.name.to_s.gsub(/^.*::/, '').to_sym
        ::Vandrake::Validator.type_registry[id] = descendant

        # Make shortname available as class attribute
        descendant.instance_eval "def validator_name; :#{id} end"
      end


      def initialize(params = {})
        @last_error = nil
        @last_error_code = nil
        validate_params(params)
        @params = params
      end


      # Resets the last error message and code for this Validator
      # @return [void]
      def reset_last_error
        @last_error = nil
        @last_error_code = nil
      end


      # This is a proxy method for running the current Validator. It resets the
      # last error code/message, makes sure the correct number of inputs were passed in,
      # and then calls the actual (protected) validation function.
      #
      # @raise [ArgumentError] If the wrong number of values are passed in
      #
      # @overload validate(value)
      #   Run simple validator with only one input
      #   @param value The value to validate
      #   @return [TrueClass, FalseClass] True on success, False on failure
      #
      # @overload validate(value1, value2)
      #   Run complex validator with multiple inputs
      #   @param value1 The value to validate
      #   @param value2 The value to validate
      #   @return [TrueClass, FalseClass] True on success, False on failure
      #
      def validate(*values)
        reset_last_error
        required_inputs = self.class.inputs

        raise ArgumentError, "This validator takes #{required_inputs} value(s) for validation, #{values.size} given" unless values.size == required_inputs

        run_validator(*values)
      end


      protected
        # Used by the Validator to set the error code and message on validation failure.
        # The message is filled in automatically by matching the code to {error_codes}.
        #
        # Some error messages have placeholders for parameters - for example, the
        # error for the Length validator will contain the actual length we're validating.
        # This will be filled in by passing the length in as a parameter here, and
        # having the method insert it into the message via sprintf().
        #
        # @param [Symbol] code The error code
        # @param params A set of optional parameters for the error message
        #
        # @return [void]
        def set_error(code, *params)
          code = code.to_sym
          raise "Unknown error code #{code} for validator #{self.class.name}" unless self.class.error_codes.key? code

          message = self.class.error_codes[code]
          message = sprintf(message, *params) unless params.empty?

          @last_error = message
          @last_error_code = code
        end

        # Check the validator parameters (if there are any).
        #
        # @param [Hash] params
        # @return [void]
        def validate_params(params)
          # This will be implemented by Validators which take parameters
        end
      # end protected
    end
  end
end