require 'spec_helper'

describe Vandrake::Validator::Format do
  context "::validate" do
    context "with parameter {:format => :email}" do
      let(:validator) { described_class.new(format: :email) }

      context "when called with nil" do
        it { validator.validate(nil).should be_true }

        subject { validator.validate(nil); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "adam@hipsnip.com"' do
        it { validator.validate("adam@hipsnip.com").should be_true }

        subject { validator.validate("adam@hipsnip.com"); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "john1000+test@gmail.com"' do
        it { validator.validate("john1000+test@gmail.com").should be_true }

        subject { validator.validate("john1000+test@gmail.com"); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "john@uni.edu.ac.uk"' do
        it { validator.validate("john@uni.edu.ac.uk").should be_true }

        subject { validator.validate("john@uni.edu.ac.uk"); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "peter@parker"' do
        it { validator.validate("peter@parker").should be_false }

        subject { validator.validate("peter@parker"); validator }
        its(:last_error_code) { should eq(:not_email) }
        its(:last_error) { should eq("has to be a valid email address") }
      end
    end


    context "with parameter {:format => :ip}" do
      let(:validator) { described_class.new(format: :ip) }

      context "when called with nil" do
        it { validator.validate(nil).should be_true }

        subject { validator.validate(nil); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "192.168.0.100"' do
        it { validator.validate("192.168.0.100").should be_true }

        subject { validator.validate("192.168.0.100"); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "11.12.13"' do
        it { validator.validate("11.12.13").should be_false }

        subject { validator.validate("11.12.13"); validator }
        its(:last_error_code) { should eq(:not_ip) }
        its(:last_error) { should eq("has to be a valid ip address") }
      end
    end


    context "with parameter {:format => :alnum}" do
      let(:validator) { described_class.new(format: :alnum) }

      context "when called with nil" do
        it { validator.validate(nil).should be_true }

        subject { validator.validate(nil); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "peter12parker34"' do
        it { validator.validate("peter12parker34").should be_true }

        subject { validator.validate("peter12parker34"); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "peter parker"' do
        it { validator.validate("peter parker").should be_false }

        subject { validator.validate("peter parker"); validator }
        its(:last_error_code) { should eq(:not_alnum) }
        its(:last_error) { should eq("can only contain letters and numbers") }
      end
    end


    context "with parameter {:format => :hex}" do
      let(:validator) { described_class.new(format: :hex) }

      context "when called with nil" do
        it { validator.validate(nil).should be_true }

        subject { validator.validate(nil); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "1a2b3c4d5e6f"' do
        it { validator.validate("1a2b3c4d5e6f").should be_true }

        subject { validator.validate("1a2b3c4d5e6f"); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "7g8h9i0j"' do
        it { validator.validate("7g8h9i0j").should be_false }

        subject { validator.validate("7g8h9i0j"); validator }
        its(:last_error_code) { should eq(:not_hex) }
        its(:last_error) { should eq("has to be a valid hexadecimal number") }
      end
    end


    context 'with parameter {:format => /^\w+$/}' do
      let(:validator) { described_class.new(format: /^\w+$/) }

      context "when called with nil" do
        it { validator.validate(nil).should be_true }

        subject { validator.validate(nil); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "mytext"' do
        it { validator.validate("mytext").should be_true }

        subject { validator.validate("mytext"); validator }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "12 34"' do
        it { validator.validate("12 34").should be_false }

        subject { validator.validate("12 34"); validator }
        its(:last_error_code) { should eq(:wrong_format) }
        its(:last_error) { should eq("has to be in the correct format") }
      end
    end


    context "called without a :format parameter" do
      it do
        expect {
          described_class.new
        }.to raise_error('Missing :format parameter for Format validator')
      end
    end


    context "called with a :format parameter that's neither Regexp nor Symbol" do
      it do
        expect {
          described_class.new(format: 123)
        }.to raise_error('The :format parameter has to be either a Symbol or a Regexp, Fixnum given')
      end
    end


    context "called with a :format Symbol which refers to a non-existent format" do
      it do
        expect {
          described_class.new(format: :magic)
        }.to raise_error('Unknown format "magic" in Format validator')
      end
    end
  end
end