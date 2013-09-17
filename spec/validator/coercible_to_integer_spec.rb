require 'spec_helper'

describe Vandrake::Validator::CoercibleToInteger do
  context "::validate" do
    subject(:validator) { described_class }

    context "when called with nil" do
      it { validator.validate(nil).should be_true }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with 100' do
      it { validator.validate(100).should be_true }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with "100"' do
      it { validator.validate("100").should be_true }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with "one"' do
      it { validator.validate("one").should be_false }
      its(:last_error_code) { should eq(:not_integer) }
      its(:last_error) { should eq("must be an integer") }
    end
  end
end