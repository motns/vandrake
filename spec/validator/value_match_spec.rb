require 'spec_helper'

describe Vandrake::Validator::ValueMatch do
  context "::validate" do
    let(:validator) { described_class.new }

    context "when called with nil, nil" do
      it { validator.validate(nil, nil).should be_true }

      subject { validator.validate(nil, nil); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with "peter parker", "batman"' do
      it { validator.validate("peter parker", "batman").should be_false }

      subject { validator.validate("peter parker", "batman"); validator }
      its(:last_error_code) { should eq(:no_match) }
      its(:last_error) { should eq("must be the same") }
    end

    context 'when called with "batman", "batman"' do
      it { validator.validate("batman", "batman").should be_true }

      subject { validator.validate("batman", "batman"); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with 25, 25' do
      it { validator.validate(25, 25).should be_true }

      subject { validator.validate(25, 25); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context 'when called with FalseClass, FalseClass' do
      it { validator.validate(false, false).should be_true }

      subject { validator.validate(false, false); validator }
      its(:last_error_code) { should be_nil }
      its(:last_error) { should be_nil }
    end

    context "called with the wrong number of arguments" do
      it do
        expect {
          validator.validate("peter parker")
        }.to raise_error("This validator takes 2 value(s) for validation, 1 given")
      end
    end
  end
end