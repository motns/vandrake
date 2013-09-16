require 'logger'

require 'vandrake/errors'
require 'vandrake/failed_validators'

require 'vandrake/validations'

require 'vandrake/validator/base'
require 'vandrake/validator/absence'
require 'vandrake/validator/boolean_coercible'
require 'vandrake/validator/exclusion'
require 'vandrake/validator/format'
require 'vandrake/validator/inclusion'
require 'vandrake/validator/integer_coercible'
require 'vandrake/validator/length'
require 'vandrake/validator/presence'
require 'vandrake/validator/value_match'

require 'vandrake/validation'
require 'vandrake/validation_chain'

# The top-level namespace for our magnificent library. Contains a few helpers,
# and a base logging facility.
module Vandrake

  # Return the current logger instance
  #
  # @return [Logger]
  def self.logger
    return @logger if defined? @logger

    @logger = ::Logger.new($stdout)
    @logger.level = ::Logger::INFO
    @logger
  end


  # Define an alternative logger to use
  #
  # @param [Logger] logger
  # @return [Logger]
  def self.logger=(logger)
    @logger = logger
  end


  # Used to extract Hash-based parameters from a list of arguments
  #
  # @example No parameters passed in
  #    Mandrake.extract_params(:one, :two) # => [:one, :two], {}
  #
  # @example Parameters Hash at the end
  #    Mandrake.extract_params(:one, :two, enable: true) # => [:one, :two], {:enable => true}
  #
  # @return [Array]
  # @return [Hash]
  def self.extract_params(*args)
    params = args.pop if args[-1].is_a?(::Hash)
    params ||= {}

    return args, params
  end
end