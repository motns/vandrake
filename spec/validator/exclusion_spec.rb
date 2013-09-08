require 'spec_helper'

describe Vandrake::Validator::Exclusion do
  context "::validate" do
    subject(:validator) { described_class }

    context "with parameter {:not_in => 0..10}" do
      context "when called with nil" do
        it { validator.validate(nil, not_in: 0..10).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context "when called with 15" do
        it { validator.validate(15, not_in: 0..10).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context "when called with 5" do
        it { validator.validate(5, not_in: 0..10).should be_false }
        its(:last_error_code) { should eq(:in_range) }
        its(:last_error) { should eq("must not be between 0 and 10") }
      end
    end


    context 'with parameter {:not_in => ["one", "two", "three"]}' do
      context 'when called with nil' do
        it { validator.validate(nil, not_in: %w(one two three)).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "four"' do
        it { validator.validate("four", not_in: %w(one two three)).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with "two"' do
        it { validator.validate("two", not_in: %w(one two three)).should be_false }
        its(:last_error_code) { should eq(:in_set) }
        its(:last_error) { should eq("must not be any of: one, two, three") }
      end
    end


    context 'with parameter {:not_in => 1.week.ago.to_date..Date.today}' do
      context 'when called with nil' do
        it { validator.validate(nil, not_in: 1.week.ago.to_date..Date.today).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with 2.weeks.ago.to_date' do
        it { validator.validate(2.weeks.ago.to_date, not_in: 1.week.ago.to_date..Date.today).should be_true }
        its(:last_error_code) { should be_nil }
        its(:last_error) { should be_nil }
      end

      context 'when called with 2.days.ago.to_date' do
        it { validator.validate(2.days.ago.to_date, not_in: 1.week.ago.to_date..Date.today).should be_false }
        its(:last_error_code) { should eq(:in_range) }
        its(:last_error) { should eq("must not be between #{1.week.ago.to_date} and #{Date.today}") }
      end
    end


    context "when called without the :not_in parameter" do
      it do
        expect {
          validator.validate("")
        }.to raise_error('Missing :not_in parameter for Exclusion validator')
      end
    end


    context "when called with {:not_in => 12} (non-Enumerable)" do
      it do
        expect {
          validator.validate("", not_in: 12)
        }.to raise_error('The :not_in parameter must be provided as an Enumerable, Fixnum given')
      end
    end
  end
end