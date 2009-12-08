require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe AffiliateBroadcast do
  fixtures :users, :affiliate_broadcasts
  before(:each) do
    @valid_attributes = {
      :user => users(:affiliate_admin),
      :subject => "Some Subject",
      :body => "The email body"
    }
  end
  
  should_belong_to :user
  should_validate_presence_of :subject
  should_validate_presence_of :body

  it "should create a new instance given valid attributes" do
    AffiliateBroadcast.create!(@valid_attributes)
  end

end
