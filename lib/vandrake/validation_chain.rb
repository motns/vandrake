module Vandrake
  # Used to create a chain consisting of {Vandrake::Validation} and {Vandrake::ValidationChain} items,
  # which will be executed in order. Validation chains are run against a {Vandrake::Model} instance,
  # with each item evaluated one at a time until a failure is encountered, or there are no more
  # items left in the chain.
  # You may use the *:continue_on_failure* setting to change the default behaviour, and not
  # stop chain execution if an item fails.
  #
  # A chain may have a set of *conditions*, which are essentially {Vandrake::Validator} classes
  # validating one or more attributes. If the validator returns true, the chain gets
  # executed. If it returns false, items in the chain will not be executed, and the
  # chain will simply return true.
  #
  # @!attribute [r] continue_on_failure
  #   @return [Boolean] Whether to continue chain execution if an item returns false
  #
  # @!attribute [r] items
  #   @return [Array] A list of {Vandrake::Validation} and {Vandrake::ValidationChain} items to execute in this chain
  #
  # @!attribute [r] conditions
  #   @return [Array] A list of {Vandrake::Validator} and attribute pairs to check before running the chain
  class ValidationChain

    attr :continue_on_failure, :items, :conditions

    # @param [Hash] params Config options
    # @option params [Boolean] :continue_on_failure (false) Whether to continue
    #   chain execution if an item returns false
    # @option params [Symbol, Array] :if_present Add condition to only run chain
    #   if the given attributes pass the {Vandrake::Validator::Presence Presence} validator
    # @option params [Symbol, Array] :if_absent Add condition to only run chain
    #   if the given attributes pass the {Vandrake::Validator::Absence Absence} validator
    #
    # @yield Executes a given block in the context of the instance, allowing you to
    #   add {Vandrake::Validator Validator} and {Vandrake::ValidationChain ValidationChain} items in a nice
    #   DSL-like syntax
    #
    # @return [ValidationChain]
    #
    # @example Create new chain with some validations
    #   Vandrake::ValidationChain.new(continue_on_failure: true) do
    #     validate :Presence, :title
    #     validate :Length, :title, length: 1..50
    #   end
    #
    def initialize(params = {}, &block)
      @continue_on_failure = params[:continue_on_failure] ? params[:continue_on_failure] : false

      @conditions = []
      generate_conditions(params)

      @items = []

      instance_eval(&block) if block_given?
    end


    # Add a new {Vandrake::Validation} instance to this chain
    #
    # @overload validate(validator, attribute)
    #   Create a validation with one attribute and no params
    #   @param [Symbol, String] validator The name of the {Vandrake::Validator} to use
    #   @param [Symbol, String] attribute The name of the attribute to validate
    #
    # @overload validate(validator, attribute1, attribute2)
    #   Create a validation with a validator that takes multiple attributes and no params
    #   @param [Symbol, String] validator The name of the {Vandrake::Validator} to use
    #   @param [Symbol, String] attribute1 The name of the first attribute argument
    #   @param [Symbol, String] attribute2 The name of the second attribute argument
    #
    # @overload validate(validator, attribute, params = {})
    #   Create a validation with one attribute and the given params
    #   @param [Symbol, String] validator The name of the {Vandrake::Validator} to use
    #   @param [Symbol, String] attribute The name of the attribute to validate
    #   @param [Hash] params The list of params to pass to the validator
    #
    # @return [Vandrake::Validation]
    #
    # @example Add new validation to chain
    #    Vandrake::ValidationChain.new.validate :Length, :name, 1..10
    #
    def validate(validator, *args)
      add Vandrake::Validation.new(validator, *args)
    end


    # Add a new {Vandrake::ValidationChain} instance to this chain
    #
    # @param (see #initialize)
    # @option (see #initialize)
    # @yield (see #initialize)
    # @return (see #initialize)
    #
    # @example Add new chain with some validations
    #   Vandrake::ValidationChain.new.chain(continue_on_failure: true) do
    #     validate :Presence, :title
    #     validate :Length, :title, length: 1..50
    #   end
    #
    def chain(params = {}, &block)
      add Vandrake::ValidationChain.new(params, &block)
    end


    # Syntactic sugar for calling {#chain} with the :if_present parameter
    # set to one or more attributes
    def if_present(*args, &block)
      attributes, params = Vandrake::extract_params(*args)
      chain({:if_present => attributes}.merge(params), &block)
    end


    # Syntactic sugar for calling {#chain} with the :if_absent parameter
    # set to one or more attributes
    def if_absent(*args, &block)
      attributes, params = Vandrake::extract_params(*args)
      chain({:if_absent => attributes}.merge(params), &block)
    end


    # Add one or more items to the validation chain
    #
    # @overload add(item)
    #   Add a single item to the chain
    #   @param [Vandrake::Validation, Vandrake::ValidationChain] item Item to add to the chain
    #
    # @overload add(item1, item2)
    #   Add multiple items to the chain (you can put down as many as you like)
    #   @param [Vandrake::Validation, Vandrake::ValidationChain] item1 First item to add to the chain
    #   @param [Vandrake::Validation, Vandrake::ValidationChain] item2 Second item to add to the chain
    #
    # @return [Vandrake::Validation, Vandrake::ValidationChain] The last item added to the chain
    #
    # @raise [ArgumentError] If one of the items passed in is neither a Validation nor a ValidationChain
    #
    # @example Add multiple items to chain
    #   validation1 = Vandrake::Validation.new(:Presence, :title)
    #   validation2 = Vandrake::Validation.new(:Presence, :name)
    #
    #   Vandrake::ValidationChain.new.add validation1, validation2
    #
    def add(*items)
      items.each do |item|
        unless item.is_a?(::Vandrake::Validation) || item.is_a?(::Vandrake::ValidationChain)
          raise ArgumentError, "Validator chain item has to be a Validator or another ValidationChain, #{item.class.name} given"
        end

        @items << item
      end

      items.last
    end


    # Execute the validation chain against the given {Vandrake::Model} instance
    #
    # @param [Vandrake::Model] document
    #
    # @return [Boolean] Returns True if the chain conditions weren't met, or if
    #   all the chain items have returned True. False otherwise.
    #
    def run(document)
      return true unless conditions_met?(document)

      success = true

      @items.each do |item|
        validation_success = item.run(document)
        success = success && validation_success
        break unless @continue_on_failure || success
      end

      success
    end


    protected

      # Transform the parameters passed to the constructor into a list of hashes
      # in the following format:
      #
      #   {
      #      :validator => Vandrake::Validator,
      #      :attribute => :attribute_name
      #   }
      #
      # and store them in the @conditions instance variable
      #
      # @param [Hash] params
      # @option params [Symbol, Array] :if_present Add condition to only run chain
      #   if the given attributes pass the {Vandrake::Validator::Presence Presence} validator
      # @option params [Symbol, Array] :if_absent Add condition to only run chain
      #   if the given attributes pass the {Vandrake::Validator::Absence Absence} validator
      #
      # @return [void]
      #
      def generate_conditions(params)
        {
          :if_present => ::Vandrake::Validator::Presence,
          :if_absent => ::Vandrake::Validator::Absence
        }.each do |condition, validator|

          if params.key? condition
            attributes = params[condition].is_a?(::Array) ? params[condition] : [ params[condition] ]

            attributes.each do |attribute|
              @conditions << {
                :validator => validator,
                :attribute => attribute
              }
            end
          end
        end
      end



      # Test the defined confitions against a given {Vandrake::Model} instance
      #
      # @note It is currently possible to put conflicting conditions in place, like
      #   an :if_present and :if_absent clause with the same attribute. Basically,
      #   we'll let people shoot themselves in the foot, if they so please. If this
      #   becomes a problem, we can start putting more validation in here, but for now
      #   I prefer to keep things simple.
      #
      # @param [Vandrake::Model] document The document to test with
      #
      # @return [Boolean] returns True if all conditions were met, or if there are
      #   no conditions defined. False otherwise.
      #
      def conditions_met?(document)
        return true if @conditions.empty?

        @conditions.each do |condition|
          return false unless condition[:validator].new.validate(document.read_attribute(condition[:attribute]))
        end

        true
      end

    # end protected
  end
end