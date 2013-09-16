require 'active_support/time'
require 'simplecov'
require 'coveralls'

SimpleCov.formatter = SimpleCov::Formatter::MultiFormatter[
  SimpleCov::Formatter::HTMLFormatter,
  Coveralls::SimpleCov::Formatter
]

SimpleCov.start do
  add_filter "spec/"
  add_filter "vendor/"
  add_group "Validators", "lib/vandrake/validator"
end

require 'vandrake'

class TestBaseModel
  include Vandrake::Validations

  def initialize(attributes)
    @attributes = attributes
  end

  def read_attribute(key)
    @attributes[key]
  end
end

class TestBaseWithRawModel < TestBaseModel
  def initialize(attributes, raw_attributes)
    super(attributes)
    @raw_attributes = raw_attributes
  end

  def read_attribute_before_type_cast(key)
    @raw_attributes[key]
  end
end