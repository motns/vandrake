require 'spec_helper'

describe Vandrake::Validator::Absence do
  context "::validate" do
    let(:validator) { described_class.new }

    context "when called with nil" do
      it { validator.validate(nil).should be_true }

      subject { validator.validate(nil); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with ""' do
      it { validator.validate("").should be_true }

      subject { validator.validate(""); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context "when called with FalseClass" do
      it { validator.validate(false).should be_false }

      subject { validator.validate(false); validator }
      its(:last_error_code) { should eq(:present) }
      its(:last_error) { should eq("must be absent") }
    end

    context "when called with 0" do
      it { validator.validate(0).should be_false }

      subject { validator.validate(0); validator }
      its(:last_error_code) { should eq(:present) }
      its(:last_error) { should eq("must be absent") }
    end

    context 'when called with "Peter Parker"' do
      it { validator.validate("Peter Parker").should be_false }

      subject { validator.validate("Peter Parker"); validator }
      its(:last_error_code) { should eq(:present) }
      its(:last_error) { should eq("must be absent") }
    end
  end
end