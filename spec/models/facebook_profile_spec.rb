require 'spec/spec_helper'

describe FacebookProfile do
  fixtures :affiliates
  
  before do
    @affiliate = affiliates(:basic_affiliate)
    @valid_attributes = {
      :username => 'USAgency',
      :affiliate => @affiliate
    }
  end
  
  it { should validate_presence_of :username }
  it { should validate_presence_of :affiliate }
  
  it "should create a new instance with valid attributes" do
    FacebookProfile.create!(@valid_attributes)
    should validate_uniqueness_of(:username).scoped_to(:affiliate_id)
  end
  
  it "should strip whitespace from the username before saving" do
    profile = FacebookProfile.create(:affiliate => @affiliate, :username => '   whitehouse   ')
    profile.username.should == 'whitehouse'
  end
end
