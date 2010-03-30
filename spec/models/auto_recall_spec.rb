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

  should_belong_to :recall

  it "should create a new instance given valid attributes" do
    AutoRecall.create!(@valid_attributes)
  end
end
