require 'spec_helper'

describe Vandrake::Validator::Length do
  context "::validate" do
    subject(:validator) { described_class }

    context "with parameter {:length => 4..10}" do
      let(:validator) { described_class.new(length: 4..10) }

      context "when called with nil" do
        it { validator.validate(nil).should be_true }

        subject { validator.validate(nil); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context "when called with 123" do
        it { validator.validate(123).should be_true }

        subject { validator.validate(123); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context "when called with FalseClass" do
        it { validator.validate(false).should be_true }

        subject { validator.validate(false); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "peter"' do
        it { validator.validate("peter").should be_true }

        subject { validator.validate("peter"); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "jon" (too short)' do
        it { validator.validate("jon").should be_false }

        subject { validator.validate("jon"); validator }
        its(:last_error_code) { should eq(:short) }
        its(:last_error) { should eq("has to be longer than 4 characters") }
      end

      context 'when called with "this is way too long"' do
        it { validator.validate("this is way too long").should be_false }

        subject { validator.validate("this is way too long"); validator }
        its(:last_error_code) { should eq(:long) }
        its(:last_error) { should eq("has to be 10 characters or less") }
      end
    end


    context "called without a :length parameter" do
      it do
        expect {
          described_class.new
        }.to raise_error('Missing :legth parameter for Length validator')
      end
    end


    context "called with a non-Range :length parameter" do
      it do
        expect {
          described_class.new(length: 12)
        }.to raise_error('The :length parameter has to be provided as a Range, Fixnum given')
      end
    end
  end
end