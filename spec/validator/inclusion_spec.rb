require 'spec_helper'

describe Vandrake::Validator::Inclusion do
  context "::validate" do
    subject(:validator) { described_class }

    context "with parameter {:in => 0..10}" do
      context "when called with nil" do
        it { validator.validate(nil, in: 0..10).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context "when called with 5" do
        it { validator.validate(5, in: 0..10).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context "when called with 15" do
        it { validator.validate(15, in: 0..10).should be_false }
        its(:last_error_code) { should eq(:not_in_range) }
        its(:last_error) { should eq("must be between 0 and 10") }
      end
    end


    context 'with parameter {:in => ["one", "two", "three"]}' do
      context 'when called with nil' do
        it { validator.validate(nil, in: %w(one two three)).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "two"' do
        it { validator.validate("two", in: %w(one two three)).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "four"' do
        it { validator.validate("four", in: %w(one two three)).should be_false }
        its(:last_error_code) { should eq(:not_in_set) }
        its(:last_error) { should eq("must be one of: one, two, three") }
      end
    end


    context 'with parameter {:in => 1.week.ago.to_date..Date.today}' do
      context 'when called with nil' do
        it { validator.validate(nil, in: 1.week.ago.to_date..Date.today).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with 2.weeks.ago.to_date' do
        it { validator.validate(2.days.ago.to_date, in: 1.week.ago.to_date..Date.today).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with 2.days.ago.to_date' do
        it { validator.validate(2.weeks.ago.to_date, in: 1.week.ago.to_date..Date.today).should be_false }
        its(:last_error_code) { should eq(:not_in_range) }
        its(:last_error) { should eq("must be between #{1.week.ago.to_date} and #{Date.today}") }
      end
    end


    context "called without the :in parameter" do
      it do
        expect {
          validator.validate("")
        }.to raise_error('Missing :in parameter for Inclusion validator')
      end
    end


    context "called with a non-Enumerable :in parameter" do
      it "throws an exception" do
        expect {
          validator.validate("", in: 12)
        }.to raise_error('The :in parameter must be provided as an Enumerable, Fixnum given')
      end
    end
  end
end