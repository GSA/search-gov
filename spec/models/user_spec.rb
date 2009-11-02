require "#{File.dirname(__FILE__)}/../spec_helper"

describe User do
  fixtures :users

  before do
    @valid_attributes = {
      :email => "unique_login@login.com",
      :password => "password",
      :password_confirmation => "password"
    }
  end

  describe "when validating" do
    should_validate_presence_of :email
    should_validate_uniqueness_of :email

    it "should create a new instance given valid attributes" do
      User.create!(@valid_attributes)
    end
  end
end