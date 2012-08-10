require 'spec/spec_helper'

describe AutoRecall do
  before(:each) do
    @valid_attributes = {
      :make => 'TOYOTA',
      :model => 'CAMRY',
      :year => 2006,
      :component_description => 'BRAKE PEDAL',
      :manufacturer => 'Toyota Motor Corporation',
      :recalled_component_id => '000000000012321320020202V00',
      :manufacturing_begin_date => Date.parse('2005-01-01'),
      :manufacturing_end_date => Date.parse('2005-12-31')
    }
  end

  it { should belong_to :recall }

  it "should create a new instance given valid attributes" do
    AutoRecall.create!(@valid_attributes)
  end

  describe "#as_json" do
    it "should return JSON the includes all the fields" do
      auto_recall = AutoRecall.create!(@valid_attributes)
      hash = AutoRecall.find(auto_recall.id).as_json
      hash['make'].should == @valid_attributes[:make]
      hash['model'].should == @valid_attributes[:model]
      hash['year'].should == @valid_attributes[:year]
      hash['component_description'].should == @valid_attributes[:component_description]
      hash['manufacturer'].should == @valid_attributes[:manufacturer]
      hash['recalled_component_id'].should == @valid_attributes[:recalled_component_id]
      hash['manufacturing_begin_date'].should == '2005-01-01'
      hash['manufacturing_end_date'].should == '2005-12-31'
    end

    it "should not contain manufacturing_begin_date if it's in the except list" do
      auto_recall = AutoRecall.create!(@valid_attributes)
      hash = AutoRecall.find(auto_recall.id).as_json(:except => :manufacturing_begin_date)
      hash.keys.should_not include('manufacturing_begin_date')
    end

    it "should not contain manufacturing_end_date if it's in the except list" do
      auto_recall = AutoRecall.create!(@valid_attributes)
      hash = AutoRecall.find(auto_recall.id).as_json(:except => :manufacturing_end_date)
      hash.keys.should_not include('manufacturing_end_date')
    end
  end
end
