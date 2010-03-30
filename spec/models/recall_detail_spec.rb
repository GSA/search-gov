require "#{File.dirname(__FILE__)}/../spec_helper"

describe RecallDetail do
  before(:each) do
    @valid_attributes = {
      :recall_id => 12345,
      :detail_type => 'Type',
      :detail_value => 'Value'
    }
  end

  should_validate_presence_of :detail_type, :detail_value
  should_belong_to :recall

  it "should create a new instance given valid attributes" do
    RecallDetail.create!(@valid_attributes)
  end

end