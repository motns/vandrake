module Vandrake
  module Validator
    # Used to validate whether a given value can be reliable coerced into an Integer
    class CoercibleToInteger < Base

      @error_codes = {
        :not_integer => "must be an integer"
      }

      @is_raw = true

      protected
        # Run validation. Returns True if the given value can be safely converted
        # to an Integer type.
        #
        # @param value
        # @return [TrueClass, FalseClass] Validation success
        def self.run_validator(value, params={})
          return true if value.nil?

          begin
            Integer(value)
            return true
          rescue ArgumentError
            set_error :not_integer
            return false
          end
        end
      # end Protected
    end
  end
end