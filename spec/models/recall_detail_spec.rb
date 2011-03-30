require "#{File.dirname(__FILE__)}/../spec_helper"

describe RecallDetail do
  before(:each) do
    @valid_attributes = {
      :recall_id => 12345,
      :detail_type => 'Type',
      :detail_value => 'Value'
    }
  end

  it { should validate_presence_of :detail_type }
  it { should validate_presence_of :detail_value }
  it { should belong_to :recall }

  it "should create a new instance given valid attributes" do
    RecallDetail.create!(@valid_attributes)
  end

end