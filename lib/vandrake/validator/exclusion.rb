module Vandrake
  module Validator
    # Used to validate whether a given value is not included in a pre-defined set or Range.
    # The opposite of {Vandrake::Validator::Inclusion}.
    class Exclusion < Base

      @error_codes = {
        :in_range => "must not be between %s and %s",
        :in_set => "must not be any of: %s"
      }

      protected
        # @raise [ArgumentError] If the :not_in parameter is not defined
        # @raise [ArgumentError] If the :not_in parameter is not an Enumerable
        #
        # @param [Hash] params
        # @option params [Enumerable] :not_in The set we're checking the membership against
        # @return [void]
        def validate_params(params)
          raise ArgumentError, "Missing :not_in parameter for Exclusion validator" unless params.key? :not_in
          raise ArgumentError, "The :not_in parameter must be provided as an Enumerable, #{params[:not_in].class.name} given" unless params[:not_in].respond_to?(:include?)
        end


        # Run validation. Returns True if the given value is not included in the set, False
        # otherwise.
        #
        # @param value
        # @return [TrueClass, FalseClass] Validation success
        def run_validator(value)
          return true if value.nil?

          if @params[:not_in].include? value
            if @params[:not_in].is_a?(::Range)
              set_error :in_range, @params[:not_in].min, @params[:not_in].max
            else
              set_error :in_set, @params[:not_in].to_a.join(', ')
            end

            false
          else
            true
          end
        end
      # end Protected
    end
  end
end