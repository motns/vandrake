module Vandrake
  # Validators are used to statically validate a single value, and provide additional
  # feedback in the form of error messages and codes upon failure. They are only
  # ever used as static classes.
  #
  # Each validator has a pre-defined number of inputs. "Simple" validators (like {Vandrake::Validator::Length})
  # take a single value, whereas "complex" validators (like {Vandrake::Validator::ValueMatch}) take
  # two or more.
  #
  # When a Validator fails, it sets *last_error* and *last_error_code*
  # on the Validator class to reflect the exact nature of the failure. This value
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

      # Used to define all the possible error codes, and respectice messages for
      # a given Validator
      @error_codes = {}


      # The number of arguments this Validator takes. Defaults to 1.
      # @return [Fixnum]
      def self.inputs
        @inputs ||= 1
      end


      # Whether this Validator operates on the non-type-cast (raw) attribute.
      # Defaults to False.
      # @return [Boolean]
      def self.raw?
        @is_raw ||= false
      end


      # Returns the error codes and messages for this Validator in the following format:
      #
      #   {
      #      :error_code1 => :error_message1,
      #      :error_code2 => :error_message2
      #   }
      #
      # @return [Hash]
      def self.error_codes
        @error_codes
      end


      # Returns the error message for the last validation with this Validator
      #
      # @return [String, NilClass] Error message if there was a failure, nil otherwise
      def self.last_error
        @last_error ||= nil
      end


      # Returns the error code for the last validation with this Validator
      #
      # @return [Symbol, NilClass] Error code if there was a failure, nil otherwise
      def self.last_error_code
        @last_error_code ||= nil
      end


      # Resets the last error message and code for this Validator
      # @return [void]
      def self.reset_last_error
        @last_error = nil
        @last_error_code = nil
      end


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
      def self.set_error(code, *params)
        code = code.to_sym
        raise "Unknown error code #{code} for validator #{self.name}" unless @error_codes.key? code

        message = @error_codes[code]
        message = sprintf(message, *params) unless params.empty?

        @last_error = message
        @last_error_code = code
      end


      # This is a proxy method for running the current Validator. It resets the
      # last error code/message, makes sure the correct number of inputs were passed in,
      # and then calls the actual (protected) validation function.
      #
      # @raise [ArgumentError] If the wrong number of values are passed in
      #
      # @overload validate(value, params = {})
      #   Run simple validator with only one input, and optional parameters
      #   @param value The value to validate
      #   @param [Hash] params Optional parameters to pass to the validator
      #   @return [TrueClass, FalseClass] True on success, False on failure
      #
      # @overload validate(value1, value2, params = {})
      #   Run complex validator with multiple inputs, and optional parameters
      #   @param value1 The value to validate
      #   @param value2 The value to validate
      #   @param [Hash] params Optional parameters to pass to the validator
      #   @return [TrueClass, FalseClass] True on success, False on failure
      #
      def self.validate(*args)
        reset_last_error

        values, params = Vandrake::extract_params(*args)

        raise ArgumentError, "This validator takes #{inputs} value(s) for validation, #{args.size} given" unless values.size == inputs

        run_validator(*values, params)
      end


      # Used to add Type classes to the central registry
      #
      # @param [Class] descendant
      def self.inherited(descendant)
        id = descendant.name.to_s.gsub(/^.*::/, '').to_sym
        ::Vandrake::Validator.type_registry[id] = descendant
      end
    end
  end
end