require "#{File.dirname(__FILE__)}/../spec_helper"

describe User do
  fixtures :users

  before do
    @valid_attributes = {
      :email => "unique_login@login.com",
      :password => "password",
      :password_confirmation => "password",
      :contact_name => "Some One"
    }
  end

  describe "when validating" do
    should_validate_presence_of :email
    should_validate_uniqueness_of :email
    should_have_many :affiliates

    it "should create a new instance given valid attributes" do
      User.create!(@valid_attributes)
    end

  end

  describe "when saving/updating" do
    it { should allow_mass_assignment_of(:crypted_password, :email) }
    it { should_not allow_mass_assignment_of(:is_affiliate_admin) }
    it { should_not allow_mass_assignment_of(:is_affiliate) }
    it { should_not allow_mass_assignment_of(:is_analyst) }
  end
end