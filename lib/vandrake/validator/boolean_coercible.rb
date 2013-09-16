module Vandrake
  module Validator
    # Used to validate whether a given value can be reliable coerced into Boolean
    class BooleanCoercible < Base

      @error_codes = {
        :not_boolean => "must be one of: true, false, 1, 0"
      }

      @is_raw = true

      protected
        # Run validation. Returns True if the given value can be safely converted
        # to a boolean type.
        #
        # @param value
        # @return [TrueClass, FalseClass] Validation success
        def self.run_validator(value, params={})
          return true if value.nil?

          if value.respond_to?(:to_s) && ["true", "false", "0", "1"].include?(value.to_s.downcase)
            true
          else
            set_error :not_boolean
            false
          end
        end
      # end Protected
    end
  end
end