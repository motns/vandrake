require 'spec_helper'

describe Vandrake::Validator::Absence do
  context "::validate" do
    subject(:validator) { described_class }

    context "when called with nil" do
      it { validator.validate(nil).should be_true }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with ""' do
      it { validator.validate("").should be_true }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context "when called with FalseClass" do
      it { validator.validate(false).should be_false }
      its(:last_error_code) { should eq(:present) }
      its(:last_error) { should eq("must be absent") }
    end

    context "when called with 0" do
      it { validator.validate(0).should be_false }
      its(:last_error_code) { should eq(:present) }
      its(:last_error) { should eq("must be absent") }
    end

    context 'when called with "Peter Parker"' do
      it { validator.validate("Peter Parker").should be_false }
      its(:last_error_code) { should eq(:present) }
      its(:last_error) { should eq("must be absent") }
    end
  end
end