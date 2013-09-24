require 'spec_helper'

describe Vandrake::Validator::CoercibleToBoolean do
  context "::validate" do
    let(:validator) { described_class.new }

    context "when called with nil" do
      it { validator.validate(nil).should be_true }

      subject { validator.validate(nil); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with "true"' do
      it { validator.validate("true").should be_true }

      subject { validator.validate("true"); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with "false"' do
      it { validator.validate("false").should be_true }

      subject { validator.validate("false"); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context "when called with 0" do
      it { validator.validate(0).should be_true }

      subject { validator.validate(0); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context "when called with 1" do
      it { validator.validate(1).should be_true }

      subject { validator.validate(1); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with "yep"' do
      it { validator.validate("yep").should be_false }

      subject { validator.validate("yep"); validator }
      its(:last_error_code) { should eq(:not_boolean) }
      its(:last_error) { should eq("must be one of: true, false, 1, 0") }
    end
  end
end