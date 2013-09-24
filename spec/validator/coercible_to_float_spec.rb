require 'spec_helper'

describe Vandrake::Validator::CoercibleToFloat do
  context "::validate" do
    let(:validator) { described_class.new }

    context "when called with nil" do
      it { validator.validate(nil).should be_true }

      subject { validator.validate(nil); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with 10' do
      it { validator.validate(10).should be_true }

      subject { validator.validate(10); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with 10.2' do
      it { validator.validate(10.2).should be_true }

      subject { validator.validate(10.2); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with "10"' do
      it { validator.validate("10").should be_true }

      subject { validator.validate("10"); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with "10.2"' do
      it { validator.validate("10.2").should be_true }

      subject { validator.validate("10.2"); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with "one"' do
      it { validator.validate("one").should be_false }

      subject { validator.validate("one"); validator }
      its(:last_error_code) { should eq(:not_float) }
      its(:last_error) { should eq("must be a float") }
    end
  end
end