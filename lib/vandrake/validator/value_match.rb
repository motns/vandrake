module Vandrake
  module Validator
    # Complex validator used to check if two values match (using ===)
    class ValueMatch < Base

      @error_codes = {
        :no_match => "must be the same"
      }

      # Indicate that this is a complex validator
      @inputs = 2

      protected
        # Run validation. Returns True if value1 and value2 match, False otherwise.
        #
        # @param value1
        # @param value2
        # @return [TrueClass, FalseClass] Validation success
        def self.run_validator(value1, value2, params={})
          return true if value1.nil? && value2.nil?

          if value1 === value2
            true
          else
            set_error :no_match
            false
          end
        end
      # end Protected
    end
  end
end