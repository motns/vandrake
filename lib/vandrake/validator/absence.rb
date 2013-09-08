module Vandrake
  module Validator
    # Used to validate whether a given value is not set (or empty). The opposite
    # of {Vandrake::Validator::Presence}.
    class Absence < Base

      @error_codes = {
        :present => "must be absent"
      }

      protected
        # Run validation. Returns True if the given value is nil or empty, False
        # otherwise.
        #
        # @param value
        # @return [TrueClass, FalseClass] Validation success
        def self.run_validator(value, params={})
          if value.nil? || (value.respond_to?(:empty?) && value.empty?)
            true
          else
            set_error :present
            false
          end
        end
      # end Protected
    end
  end
end