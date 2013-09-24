module Vandrake
  module Validator
    # Used to validate whether a given value can be reliable coerced into a Float
    class CoercibleToFloat < Base

      @error_codes = {
        :not_float => "must be a float"
      }

      @is_raw = true

      protected
        # Run validation. Returns True if the given value can be safely converted
        # to a Float type.
        #
        # @param value
        # @return [TrueClass, FalseClass] Validation success
        def run_validator(value)
          return true if value.nil?

          begin
            Float(value)
            return true
          rescue ArgumentError
            set_error :not_float
            return false
          end
        end
      # end Protected
    end
  end
end