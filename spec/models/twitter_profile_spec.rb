require 'spec/spec_helper'

describe TwitterProfile do
  before do
    @valid_attributes = {
      :twitter_id => 123,
      :screen_name => 'USASearch'
    }
  end
  
  it { should validate_presence_of :twitter_id }
  it { should validate_presence_of :screen_name }
  it "should create an instance with valid attributes" do
    TwitterProfile.create!(@valid_attributes)
  
    should validate_uniqueness_of :twitter_id 
    should validate_uniqueness_of :screen_name
  end
  it { should have_many :tweets }
  it { should have_and_belong_to_many :affiliates }
end
