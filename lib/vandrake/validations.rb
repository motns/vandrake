module Vandrake
  # Used to add methods for creating and running {Vandrake::ValidationChain} items
  # to validate the data in a mode instance.
  module Validations
    extend ActiveSupport::Concern

    # @TODO - Support for these in Mandrake?
    # included do |base|
    #   base.define_model_callbacks :validation, only: [:before, :after]
    #   base.after_attribute_change { |doc| doc.reset_validated }
    # end


    # Returns whether or not this Model instance has been validated
    # with the current data.
    #
    # @return [TrueClass, FalseClass]
    def validated?
      @validated ||= false # @MOTNS - Only include this in Mandrake-specific mode?
    end


    # Reset the value for @validated to False - this will force all the validations
    # to be executed, the next time {#valid?} is called
    def reset_validated
      @validated = false
    end

    protected :validated?, :reset_validated


    # Returns the {Vandrake::FailedValidators} instance for the current {Vandrake::Model} instance
    #
    # @return [Vandrake::FailedValidators]
    def failed_validators
      @failed_validators ||= Vandrake::FailedValidators.new
    end


    # Shortcut for getting the main {Vandrake::ValidationChain} for the current {Vandrake::Model} class
    #
    # @return [Vandrake::ValidationChain]
    def validation_chain
      self.class.validation_chain
    end


    # Runs validations and returns a Boolean indicating whether the current {Vandrake::Model}
    # instance data is valid
    #
    # @return [TrueClass, FalseClass]
    def valid?
      run_validations unless validated?
      failed_validators.list.empty?
    end


    # Run the main validation chain for this {Vandrake::Model} instance
    #
    # @return [TrueClass, FalseClass]
    def run_validations
      run_callbacks :validation do
        failed_validators.clear
        validation_chain.run(self)

        @embedded_models.each do |name, embedded_model|
          unless embedded_model.model.valid?
            failed_validators.include_embedded_model(name, embedded_model.model.failed_validators)
            break
          end
        end

        @validated = true
      end
    end
    protected :run_validations


    # Methods to extend the class we're included in
    module ClassMethods
      # Returns the {Vandrake::ValidationChain} for the current {Vandrake::Model} class
      #
      # @return [Vandrake::ValidationChain]
      def validation_chain
        @validation_chain ||= Vandrake::ValidationChain.new
      end


      # Returns the {Vandrake::ValidationChain} used specifically to validate attributes
      # in the current {Vandrake::Model} class. This chain is part of the main validation
      # chain, but can be accessed directly so we can keep adding validation chains
      # for each newly defined key.
      #
      # @return [Vandrake::ValidationChain]
      def attribute_chain
        return @attribute_chain if defined?(@attribute_chain)
        @attribute_chain = validation_chain.chain(continue_on_failure: true)
      end


      # Proxies to main validation chain
      # @see Vandrake::ValidationChain#validate
      def validate(validator, *args); validation_chain.validate(validator, *args); end

      # Proxies to main validation chain
      # @see Vandrake::ValidationChain#chain
      def chain(params = {}, &block); validation_chain.chain(params, &block); end

      # Proxies to main validation chain
      # @see Vandrake::ValidationChain#if_present
      def if_present(params = {}, &block); validation_chain.if_present(params, &block); end

      # Proxies to main validation chain
      # @see Vandrake::ValidationChain#if_absent
      def if_absent(params = {}, &block); validation_chain.if_absent(params, &block); end


      # Creates a {Vandrake::ValidationChain} in the {#attribute_chain} for a newly
      # defined key. It looks at key parameters, and sets up the appropriate
      # {Vandrake::Validator} items.
      #
      # @param [Vandrake::Key] key
      # @return [void]
      def create_validations_for(key)
        key_name = key.name
        key_params = key.params

        # Skip the chain if a non-required key is empty
        params = key.required ? {} : {:if_present => key_name}

        attribute_chain.chain(params) do
          validate :Presence, key_name if key.required
          validate :Format, key_name, format: key_params[:format] if key_params[:format]
          validate :Length, key_name, length: key_params[:length] if key_params[:length]
          validate :Inclusion, key_name, in: key_params[:in] if key_params[:in]
          validate :Exclusion, key_name, not_in: key_params[:not_in] if key_params[:not_in]
        end
      end
    end
  end
end