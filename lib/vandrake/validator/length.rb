module Vandrake
  module Validator
    # Checks whether the length of a value is within a given Range
    class Length < Base

      @error_codes = {
        :short => "has to be longer than %d characters",
        :long => "has to be %d characters or less"
      }

      protected
        # @param [Hash] params
        # @option params [Range] :length The Range defining the length to test
        #
        # @raise [ArgumentError] If the :length parameter is not defined
        # @raise [ArgumentError] If the :length parameter is not a Range
        def validate_params(params)
          raise ArgumentError, "Missing :legth parameter for Length validator" unless params.key? :length
          raise ArgumentError, "The :length parameter has to be provided as a Range, #{params[:length].class.name} given" unless params[:length].is_a?(::Range)
        end


        # Run validation. Returns True if the given value is the right length, False
        # otherwise.
        #
        # @param value
        # @return [TrueClass, FalseClass] Validation success
        def run_validator(value)
          return true if value.nil?

          min_length = @params[:length].min
          max_length = @params[:length].max

          if value.respond_to? :length
            if value.length < min_length
              set_error :short, min_length
              false
            elsif value.length > max_length
              set_error :long, max_length
              false
            else
              true
            end
          else
            true
          end
        end
      # end Protected
    end
  end
end