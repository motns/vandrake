module Vandrake
  module Validator
    # Used to validate whether a given value is included in a pre-defined set or Range.
    # The opposite of {Vandrake::Validator::Exclusion}.
    class Inclusion < Base

      @error_codes = {
        :not_in_range => "must be between %s and %s",
        :not_in_set => "must be one of: %s"
      }

      protected
        # Run validation. Returns True if the given value is included in the set, False
        # otherwise.
        #
        # @param value
        # @param [Hash] params
        # @option params [Enumerable] :in The set we're checking the membership against
        #
        # @raise [ArgumentError] If the :in parameter is not defined
        # @raise [ArgumentError] If the :in parameter is not an Enumerable
        #
        # @return [TrueClass, FalseClass] Validation success
        def self.run_validator(value, params={})
          return true if value.nil?

          raise ArgumentError, "Missing :in parameter for Inclusion validator" unless params.key? :in
          raise ArgumentError, "The :in parameter must be provided as an Enumerable, #{params[:in].class.name} given" unless params[:in].respond_to?(:include?)

          if params[:in].include? value
            true
          else
            if params[:in].is_a?(::Range)
              set_error :not_in_range, params[:in].min, params[:in].max
            else
              set_error :not_in_set, params[:in].to_a.join(', ')
            end

            false
          end
        end
      # end Protected
    end
  end
end