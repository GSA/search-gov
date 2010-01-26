require "#{File.dirname(__FILE__)}/../spec_helper"

describe User do
  fixtures :users

  before do
    @valid_attributes = {
      :email => "unique_login@agency.gov",
      :password => "password",
      :password_confirmation => "password",
      :contact_name => "Some One",
      :phone=> "301-123-4567",
      :address=> "123 Penn Ave",
      :address2=> "Ste 100",
      :city=> "Reston",
      :state=> "VA",
      :zip=> "20022",
      :organization_name=> "Agency"
    }
  end

  describe "when validating" do
    should_validate_presence_of :email
    should_validate_uniqueness_of :email
    should_validate_presence_of :phone
    should_validate_presence_of :zip
    should_validate_presence_of :organization_name
    should_validate_presence_of :address
    should_validate_presence_of :state
    should_validate_presence_of :time_zone
    should_validate_presence_of :contact_name

    should_have_many :affiliates

    it "should create a new instance given valid attributes" do
      User.create!(@valid_attributes)
    end

    it "should require a dot gov email address" do
      u = User.new(@valid_attributes.merge(:email => "foo@notadot.gov.biz"))
      u.valid?.should be_false
    end

  end

  describe "when saving/updating" do
    it { should allow_mass_assignment_of(:crypted_password, :email) }
    it { should_not allow_mass_assignment_of(:is_affiliate_admin) }
    it { should_not allow_mass_assignment_of(:is_affiliate) }
    it { should_not allow_mass_assignment_of(:is_analyst) }
  end
end