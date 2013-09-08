module Vandrake
  module Validator
    # Used to validate whether a given value is set and not empty. The opposite
    # of {Vandrake::Validator::Absence}.
    class Presence < Base

      @error_codes = {
        :missing => "must be provided",
        :empty => "cannot be empty"
      }

      protected
        # Run validation. Returns False if the given value is nil or empty, True
        # otherwise.
        #
        # @param value
        # @return [TrueClass, FalseClass] Validation success
        def self.run_validator(value, params={})
          if value.nil?
            set_error :missing
            false
          elsif value.respond_to?(:empty?) && value.empty?
            set_error :empty
            false
          else
            true
          end
        end
      # end Protected
    end
  end
end