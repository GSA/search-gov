require 'spec/spec_helper'

describe AffiliateBroadcast do
  fixtures :users, :affiliate_broadcasts
  before(:each) do
    @valid_attributes = {
      :user => users(:affiliate_admin),
      :subject => "Some Subject",
      :body => "The email body"
    }
  end

  describe "when creating a new instance" do
    it { should belong_to :user }
    it { should validate_presence_of :subject }
    it { should validate_presence_of :body }

    it "should create a new instance given valid attributes" do
      AffiliateBroadcast.create!(@valid_attributes)
    end

    it "should enqueue the broadcast for processing via Resque" do
      ResqueSpec.reset!
      AffiliateBroadcast.create!(@valid_attributes)
      SendAffiliateBroadcast.should have_queued(@valid_attributes[:subject], @valid_attributes[:body])
    end
  end
end
