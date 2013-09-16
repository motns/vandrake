require 'spec_helper'

describe Vandrake::Validation do
  context "::initialize" do
    context "called with :Presence, :title" do
      subject { described_class.new(:Presence, :title) }
      its(:validator_name) { should eq(:Presence) }
      its(:validator_class) { should eq(Vandrake::Validator::Presence) }
      its(:attributes) { should include(:title) }
    end


    context "called with :ValueMatch, :password, :password_confirm" do
      subject { described_class.new(:ValueMatch, :password, :password_confirm) }
      its(:validator_name) { should eq(:ValueMatch) }
      its(:validator_class) { should eq(Vandrake::Validator::ValueMatch) }
      its(:attributes) { should include(:password) }
      its(:attributes) { should include(:password_confirm) }
    end


    context "called with String, :vehicle (validator can't be converted to Symbol)" do
      it do
        expect {
          described_class.new(String, :vehicle)
        }.to raise_error("Validator name should be provided as a Symbol, Class given")
      end
    end


    context "called with :Batmobil (validator doesn't exist)" do
      it do
        expect {
          described_class.new(:Batmobil, :vehicle)
        }.to raise_error("Unknown validator: Batmobil")
      end
    end


    context "called with :Presence, 123 (attribute can't be converted to Symbol)" do
      it do
        expect {
          described_class.new(:Presence, 123)
        }.to raise_error("Attribute name has to be a Symbol, Fixnum given")
      end
    end
  end


  context "#run" do
    context "with a single-field validator with no parameters" do
      before(:all) do
        @validation = described_class.new(:Presence, :title)
      end

      context "and a document with a valid attribute" do
        before(:all) do
          @doc = TestBaseModel.new({:title => "Bruce Wayne"})
        end

        it "returns true" do
          @validation.run(@doc).should be_true
        end

        it "adds no failed validators" do
          @doc.failed_validators.list.should be_empty
        end
      end

      context "and a document with an invalid attribute" do
        before(:all) do
          @doc = TestBaseModel.new({})
        end

        it "returns false" do
          @validation.run(@doc).should be_false
        end

        it "adds the failed validator for attribute" do
          @doc.failed_validators.list.should include(:attribute)
          @doc.failed_validators.list[:attribute].should include(:title)
          @doc.failed_validators.list[:attribute][:title].should include({
            :validator => :Presence,
            :error_code => :missing,
            :message => "must be provided"
          })
        end
      end
    end


    context "with a single-field validator that takes parameters" do
      before(:all) do
        @validation = described_class.new(:Length, :title, length: 0..12)
      end

      context "and a document with a valid attribute" do
        before(:all) do
          @doc = TestBaseModel.new({:title => "Bruce Wayne"})
        end

        it "returns true" do
          @validation.run(@doc).should be_true
        end

        it "adds no failed validators" do
          @doc.failed_validators.list.should be_empty
        end
      end

      context "and a document with an invalid attribute" do
        before(:all) do
          @doc = TestBaseModel.new({:title => "The incredible Spider Man"})
        end

        it "returns false" do
          @validation.run(@doc).should be_false
        end

        it "adds the failed validator for attribute" do
          @doc.failed_validators.list.should include(:attribute)
          @doc.failed_validators.list[:attribute].should include(:title)
          @doc.failed_validators.list[:attribute][:title].should include({
            :validator => :Length,
            :error_code => :long,
            :message => "has to be 12 characters or less"
          })
        end
      end
    end


    context "with a multi-field validator" do
      before(:all) do
        @validation = described_class.new(:ValueMatch, :password, :password_confirm)
      end

      context "and a document with valid attributes" do
        before(:all) do
          @doc = TestBaseModel.new({:password => "mypass", :password_confirm => "mypass"})
        end

        it "returns true" do
          @validation.run(@doc).should be_true
        end

        it "adds no failed validators" do
          @doc.failed_validators.list.should be_empty
        end
      end

      context "and a document with an invalid attribute" do
        before(:all) do
          @doc = TestBaseModel.new({:password => "mypass", :password_confirm => "notmypass"})
        end

        it "returns false" do
          @validation.run(@doc).should be_false
        end

        it "adds the failed validator for the model" do
          @doc.failed_validators.list.should include(:model)
          @doc.failed_validators.list[:model].should include({
            :validator => :ValueMatch,
            :attributes => [:password, :password_confirm],
            :error_code => :no_match,
            :message => "must be the same"
          })
        end
      end
    end


    context "with a raw validator" do
      before(:all) do
        @validation = described_class.new(:BooleanCoercible, :is_batman)
      end

      context "and a document with a valid raw attribute" do
        before(:all) do
          @doc = TestBaseWithRawModel.new({:title => "Bruce Wayne", :is_batman => true}, {:title => "Bruce Wayne", :is_batman => 1})
        end

        it "returns true" do
          @validation.run(@doc).should be_true
        end

        it "adds no failed validators" do
          @doc.failed_validators.list.should be_empty
        end
      end

      context "and a document with an invalid raw attribute" do
        before(:all) do
          @doc = TestBaseWithRawModel.new({:title => "The incredible Spider Man", :is_batman => nil}, {:title => "The incredible Spider Man", :is_batman => 'nope'})
        end

        it "returns false" do
          @validation.run(@doc).should be_false
        end

        it "adds the failed validator for attribute" do
          @doc.failed_validators.list.should include(:attribute)
          @doc.failed_validators.list[:attribute].should include(:is_batman)
          @doc.failed_validators.list[:attribute][:is_batman].should include({
            :validator => :BooleanCoercible,
            :error_code => :not_boolean,
            :message => "must be one of: true, false, 1, 0"
          })
        end
      end
    end
  end
end