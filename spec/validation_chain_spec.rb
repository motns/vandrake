require 'spec_helper'

describe Vandrake::ValidationChain do

  context "#validate" do
    context "when called with a Validator that takes no parameters" do
      before(:all) do
        @chain = described_class.new
        @validation = @chain.validate :Presence, :title
      end

      it "adds new Validation to the chain" do
        @chain.items.should include(@validation)
      end
    end


    context "when called with a Validator that takes parameters" do
      before(:all) do
        @chain = described_class.new
        @validation = @chain.validate :Length, :title, length: 0..15
      end

      it "adds new Validation to the chain" do
        @chain.items.should include(@validation)
      end
    end
  end


  context "#chain" do
    context "when called with a block" do
      before(:all) do
        @chain = described_class.new
        @validation = validation = Vandrake::Validation.new(:Presence, :title)

        @chain2 = @chain.chain(if_present: :title) do
          add validation
        end
      end

      it "adds new ValidationChain to the chain" do
        @chain.items.should include(@chain2)
      end

      it "passes the block to new ValidationChain" do
        @chain2.items.should include(@validation)
      end
    end
  end


  context "#if_present" do
    context "when called with a block" do
      before(:all) do
        @chain = described_class.new
        @validation = validation = Vandrake::Validation.new(:Presence, :title)

        @chain2 = @chain.if_present :title do
          add validation
        end
      end

      it "adds new ValidationChain to the chain" do
        @chain.items.should include(@chain2)
      end

      it "sets the :if_present conditional on the chain" do
        @chain2.conditions.should include({
          :validator => Vandrake::Validator::Presence,
          :attribute => :title
        })
      end

      it "passes the block to new ValidationChain" do
        @chain2.items.should include(@validation)
      end
    end
  end


  context "#if_absent" do
    context "when called with a block" do
      before(:all) do
        @chain = described_class.new
        @validation = validation = Vandrake::Validation.new(:Presence, :username)

        @chain2 = @chain.if_absent :title do
          add validation
        end
      end

      it "adds new ValidationChain to the chain" do
        @chain.items.should include(@chain2)
      end

      it "sets the :if_absent conditional on the chain" do
        @chain2.conditions.should include({
          :validator => Vandrake::Validator::Absence,
          :attribute => :title
        })
      end

      it "passes the block to new ValidationChain" do
        @chain2.items.should include(@validation)
      end
    end
  end


  context "#add" do
    context "when called with a Validation" do
      before(:all) do
        @chain = described_class.new
        @validation = Vandrake::Validation.new(:Presence, :title)
        @chain.add(@validation)
      end

      it "adds item to chain" do
        @chain.items.should include(@validation)
      end
    end


    context "when called with a ValidationChain" do
      before(:all) do
        @chain = described_class.new
        @chain2 = described_class.new
        @chain.add(@chain2)
      end

      it "adds item to chain" do
        @chain.items.should include(@chain2)
      end
    end


    context "when called with item that's not Validation or ValidationChain" do
      it "raises error" do
        expect {
          described_class.new.add("stuff")
        }.to raise_error("Validator chain item has to be a Validator or another ValidationChain, String given")
      end
    end
  end


  context "#run" do
    before(:all) do
      @validation_username_presence = Vandrake::Validation.new(:Presence, :username)
      @validation_username_format = Vandrake::Validation.new(:Format, :username, format: :alnum)
      @validation_name_presence = Vandrake::Validation.new(:Presence, :name)
      @validation_bio_presence = Vandrake::Validation.new(:Presence, :bio)
    end


    context "called on a chain with no conditions" do
      context "and a single Validation in the chain" do
        before(:all) do
          @chain = described_class.new
          @chain.add(@validation_username_presence)
        end

        context "and a valid document being passed in" do
          before(:all) do
            @doc = TestBaseModel.new({:username => "batman1"})
          end

          it "returns true" do
            @chain.run(@doc).should be_true
          end

          it "adds no failed validators" do
            @doc.failed_validators.list.should be_empty
          end
        end

        context "and an invalid document being passed in" do
          before(:all) do
            @doc = TestBaseModel.new({})
          end

          it "returns false" do
            @chain.run(@doc).should be_false
          end

          it "adds the failed validator for attribute" do
            @doc.failed_validators.list.should include(:attribute)
            @doc.failed_validators.list[:attribute].should include(:username)
            @doc.failed_validators.list[:attribute][:username].should include({
              :validator => :Presence,
              :error_code => :missing,
              :message => "must be provided"
            })
          end
        end
      end


      context "with multiple Validations in the chain" do
        context "and :continue_on_failure set to false" do
          before(:all) do
            @chain = described_class.new
            @chain.add(@validation_username_presence, @validation_username_format)
          end

          context "and a valid document being passed in" do
            before(:all) do
              @doc = TestBaseModel.new({:username => "batman1"})
            end

            it "returns true" do
              @chain.run(@doc).should be_true
            end

            it "adds no failed validators" do
              @doc.failed_validators.list.should be_empty
            end
          end

          context "and an invalid document being passed in" do
            before(:all) do
              @doc = TestBaseModel.new({})
            end

            it "returns false" do
              @chain.run(@doc).should be_false
            end

            it "adds only first failed validator" do
              @doc.failed_validators.list.should include(:attribute)
              @doc.failed_validators.list[:attribute][:username].length.should eq(1)
              @doc.failed_validators.list[:attribute][:username].should include({
                :validator => :Presence,
                :error_code => :missing,
                :message => "must be provided"
              })
            end
          end
        end


        context "and :continue_on_failure set to true" do
          before(:all) do
            @chain = described_class.new(continue_on_failure: true)
            @chain.add(@validation_username_presence, @validation_username_format)
          end

          context "and an invalid document being passed in" do
            before(:all) do
              @doc = TestBaseModel.new(username: "")
            end

            it "returns false" do
              @chain.run(@doc).should be_false
            end

            it "adds all failed validators" do
              @doc.failed_validators.list.should include(:attribute)
              @doc.failed_validators.list[:attribute].should include(:username)

              @doc.failed_validators.list[:attribute][:username].should include({
                :validator => :Presence,
                :error_code => :empty,
                :message => "cannot be empty"
              })

              @doc.failed_validators.list[:attribute][:username].should include({
                :validator => :Format,
                :error_code => :not_alnum,
                :message => "can only contain letters and numbers"
              })
            end
          end
        end
      end


      context "with a Validation and another ValidationChain in the chain" do
        before(:all) do
          @chain2 = described_class.new
          @chain2.add(@validation_name_presence)
        end

        context "and :continue_on_failure set to false" do
          before(:all) do
            @chain = Vandrake::ValidationChain.new
            @chain.add(@validation_username_presence, @chain2)
          end

          context "and a valid document being passed in" do
            before(:all) do
              @doc = TestBaseModel.new({:username => "batman1", :name => "Bruce Wayne"})
            end

            it "returns true" do
              @chain.run(@doc).should be_true
            end

            it "adds no failed validators" do
              @doc.failed_validators.list.should be_empty
            end
          end

          context "and an invalid document being passed in" do
            before(:all) do
              @doc = TestBaseModel.new({})
            end

            it "returns false" do
              @chain.run(@doc).should be_false
            end

            it "adds only first failed validator" do
              @doc.failed_validators.list.should include(:attribute)
              @doc.failed_validators.list[:attribute].should include(:username)
              @doc.failed_validators.list[:attribute][:username].length.should eq(1)
              @doc.failed_validators.list[:attribute][:username].should include({
                :validator => :Presence,
                :error_code => :missing,
                :message => "must be provided"
              })
            end
          end
        end


        context "and :continue_on_failure set to true" do
          before(:all) do
            @chain = described_class.new(continue_on_failure: true)
            @chain.add(@validation_username_presence, @chain2)
          end

          context "and an invalid document being passed in" do
            before(:all) do
              @doc = TestBaseModel.new({})
            end

            it "returns false" do
              @chain.run(@doc).should be_false
            end

            it "adds all failed validators" do
              @doc.failed_validators.list.should include(:attribute)
              @doc.failed_validators.list[:attribute].should include(:username)
              @doc.failed_validators.list[:attribute].should include(:name)

              @doc.failed_validators.list[:attribute][:username].should include({
                :validator => :Presence,
                :error_code => :missing,
                :message => "must be provided"
              })

              @doc.failed_validators.list[:attribute][:name].should include({
                :validator => :Presence,
                :error_code => :missing,
                :message => "must be provided"
              })
            end
          end
        end
      end
    end


    context "called on a chain with an :if_absent condition on a single attribute" do
      before(:all) do
        @chain = described_class.new(if_absent: :username)
        @chain.add(@validation_name_presence)
      end

      context "with a document meeting that condition" do
        context "but failing the validation" do
          before(:all) do
            @doc = TestBaseModel.new({:name => ""})
          end

          it "returns false" do
            @chain.run(@doc).should be_false
          end

          it "adds failed validator" do
            @doc.failed_validators.list.should include(:attribute)
            @doc.failed_validators.list[:attribute].should include(:name)

            @doc.failed_validators.list[:attribute][:name].should include({
              :validator => :Presence,
              :error_code => :empty,
              :message => "cannot be empty"
            })
          end
        end
      end


      context "with a document not meeting that condition" do
        context "and failing the validation" do
          before(:all) do
            @doc = TestBaseModel.new({:username => "batman1", :name => ""})
          end

          it "bypasses validator and returns true" do
            @chain.run(@doc).should be_true
          end

          it "adds no failed validators from bypassed chain" do
            @doc.failed_validators.list.should be_empty
          end
        end
      end
    end


    context "called on a chain with an :if_present condition on a single attribute" do
      before(:all) do
        @chain = described_class.new(if_present: :username)
        @chain.add(@validation_name_presence)
      end

      context "with a document meeting that condition" do
        context "but failing the validation" do
          before(:all) do
            @doc = TestBaseModel.new({:username => "batman1", :name => ""})
          end

          it "returns false" do
            @chain.run(@doc).should be_false
          end

          it "adds failed validator" do
            @doc.failed_validators.list.should include(:attribute)
            @doc.failed_validators.list[:attribute].should include(:name)

            @doc.failed_validators.list[:attribute][:name].should include({
              :validator => :Presence,
              :error_code => :empty,
              :message => "cannot be empty"
            })
          end
        end
      end


      context "with a document not meeting that condition" do
        context "and failing the validation" do
          before(:all) do
            @doc = TestBaseModel.new({:name => ""})
          end

          it "bypasses validator and returns true" do
            @chain.run(@doc).should be_true
          end

          it "adds no failed validators from bypassed chain" do
            @doc.failed_validators.list.should be_empty
          end
        end
      end
    end


    context "called on a chain with an :if_absent condition on multiple attributes" do
      before(:all) do
        @chain = described_class.new(if_absent: [:name, :username])
        @chain.add(@validation_bio_presence)
      end

      context "with a document meeting that condition" do
        context "but failing the validation" do
          before(:all) do
            @doc = TestBaseModel.new({:bio => ""})
          end

          it "returns false" do
            @chain.run(@doc).should be_false
          end

          it "adds failed validator" do
            @doc.failed_validators.list.should include(:attribute)
            @doc.failed_validators.list[:attribute].should include(:bio)

            @doc.failed_validators.list[:attribute][:bio].should include({
              :validator => :Presence,
              :error_code => :empty,
              :message => "cannot be empty"
            })
          end
        end
      end


      context "with a document not meeting that condition" do
        context "and failing the validation" do
          before(:all) do
            @doc = TestBaseModel.new({:username => "batman1", :name => "Bruce Wayne", :bio => ""})
          end

          it "bypasses validator and returns true" do
            @chain.run(@doc).should be_true
          end

          it "adds no failed validators from bypassed chain" do
            @doc.failed_validators.list.should be_empty
          end
        end
      end
    end


    context "called on a chain with an :if_present condition on multiple attributes" do
      before(:all) do
        @chain = described_class.new(if_present: [:name, :username])
        @chain.add(@validation_bio_presence)
      end

      context "with a document meeting that condition" do
        context "but failing the validation" do
          before(:all) do
            @doc = TestBaseModel.new({:username => "batman1", :name => "Bruce Wayne", :bio => ""})
          end

          it "returns false" do
            @chain.run(@doc).should be_false
          end

          it "adds failed validator" do
            @doc.failed_validators.list.should include(:attribute)
            @doc.failed_validators.list[:attribute].should include(:bio)

            @doc.failed_validators.list[:attribute][:bio].should include({
              :validator => :Presence,
              :error_code => :empty,
              :message => "cannot be empty"
            })
          end
        end
      end


      context "with a document not meeting that condition" do
        context "and failing the validation" do
          before(:all) do
            @doc = TestBaseModel.new({:bio => ""})
          end

          it "bypasses validator and returns true" do
            @chain.run(@doc).should be_true
          end

          it "adds no failed validators from bypassed chain" do
            @doc.failed_validators.list.should be_empty
          end
        end
      end
    end


    context "called on a chain with both :if_present and :if_absent conditions" do
      before(:all) do
        @chain = described_class.new(if_present: :username, if_absent: :name)
        @chain.add(@validation_bio_presence)
      end

      context "with a document meeting that condition" do
        context "but failing the validation" do
          before(:all) do
            @doc = TestBaseModel.new({:username => "batman1", :bio => ""})
          end

          it "returns false" do
            @chain.run(@doc).should be_false
          end

          it "adds failed validator" do
            @doc.failed_validators.list.should include(:attribute)
            @doc.failed_validators.list[:attribute].should include(:bio)

            @doc.failed_validators.list[:attribute][:bio].should include({
              :validator => :Presence,
              :error_code => :empty,
              :message => "cannot be empty"
            })
          end
        end
      end


      context "with a document not meeting that condition" do
        context "and failing the validation" do
          before(:all) do
            @doc = TestBaseModel.new({:username => "batman1", :name => "Bruce Wayne", :bio => ""})
          end

          it "bypasses validator and returns true" do
            @chain.run(@doc).should be_true
          end

          it "adds no failed validators from bypassed chain" do
            @doc.failed_validators.list.should be_empty
          end
        end
      end
    end
  end
end