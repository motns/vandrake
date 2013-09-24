require 'spec_helper'

describe Vandrake::Validator::Base do
  context "::validate" do
    context "called with the wrong number of inputs" do
      it do
        # @NOTE: This works because the default number of expected inputs is 1
        expect {
          described_class.new.validate("my value1", "my value2")
        }.to raise_error('This validator takes 1 value(s) for validation, 2 given')
      end
    end
  end
end