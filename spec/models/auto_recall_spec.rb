require "#{File.dirname(__FILE__)}/../spec_helper"

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
  
  describe "#to_json" do
    it "should return JSON the includes all the fields" do
      @auto_recall = AutoRecall.new(@valid_attributes)
      parsed_json = JSON.parse(@auto_recall.to_json)
      parsed_json["make"].should == @valid_attributes[:make]
      parsed_json["model"].should == @valid_attributes[:model]
      parsed_json["year"].should == @valid_attributes[:year]
      parsed_json["component_description"].should == @valid_attributes[:component_description]
      parsed_json["manufacturer"].should == @valid_attributes[:manufacturer]
      parsed_json["recalled_component_id"].should == @valid_attributes[:recalled_component_id]
      parsed_json["manufacturing_begin_date"].should == @valid_attributes[:manufacturing_begin_date].to_s
      parsed_json["manufacturing_end_date"].should == @valid_attributes[:manufacturing_end_date].to_s
    end
  end
end
