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
  
  it { should belong_to :user }
  it { should validate_presence_of :subject }
  it { should validate_presence_of :body }

  it "should create a new instance given valid attributes" do
    AffiliateBroadcast.create!(@valid_attributes)
  end

end
