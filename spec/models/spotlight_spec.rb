require 'spec/spec_helper'

describe Spotlight do
  fixtures :spotlights, :spotlight_keywords, :affiliates

  before(:each) do
    @valid_attributes = {
      :title=>"My Spotlight",
      :html=>"Some HTML in a DIV",
      :notes=>"This is notable",
      :is_active => 1
    }
  end

  describe "Creating new instance" do
    it { should validate_presence_of :title }
    it { should validate_uniqueness_of :title }
    it { should have_many :spotlight_keywords }
    it { should belong_to :affiliate }

    it "should create a new instance given valid attributes" do
      Spotlight.create!(@valid_attributes)
    end
  end

  describe "#search_for" do
    before do
      @spotty = spotlights(:time)
    end

    context "when an otherwise relevant spotlight is inactive" do
      before do
        @spotty.update_attribute(:is_active, false)
        Spotlight.reindex
      end

      it "should return nil" do
        Spotlight.search_for("time").should be_nil
      end
    end

    context "when a relevant spotlight is active" do
      before do
        Spotlight.reindex
      end

      it "should return a Spotlight" do
        Spotlight.search_for("time").should == @spotty
      end
      
      it "should return nil if the search specifies an affiliate" do
        Spotlight.search_for("time", affiliates(:basic_affiliate)).should == nil
      end
    end
    
    context "when an affiliate is provided" do
      before do
        @affiliate = affiliates(:basic_affiliate)
        @spotty.update_attributes(:affiliate => @affiliate)
        Spotlight.reindex
      end
      
      it "should return a spotlight without an affiliate" do
        Spotlight.search_for("time", @affiliate).should == @spotty
        Spotlight.search_for("time").should == nil
      end
    end

    it "should instrument the call to Solr with the proper action.service namespace, and query param hash" do
      ActiveSupport::Notifications.should_receive(:instrument).
        with("solr_search.usasearch", hash_including(:query => hash_including(:model=>"Spotlight", :term => "foo")))
      Spotlight.search_for('foo')
    end

    context "an exception is raised" do
      before do
        Spotlight.stub!(:search).and_raise SocketError
      end

      it "should return nil" do
        Spotlight.search_for('foo').should be_nil
      end
    end

    after(:all) do
      Spotlight.remove_all_from_index!
    end

  end
end
