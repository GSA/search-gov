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
      :organization_name=> "Agency",
      :government_affiliation => "1"
    }

    @valid_developer_attributes = {
      :email => "some.guy@usa.gov",
      :contact_name => "Some Guy",
      :password => "password",
      :password_confirmation => "password",
      :government_affiliation => "0"
    }

    @valid_affiliate_attributes = {
      :email => "some.guy@usa.gov",
      :contact_name => "Some Guy",
      :password => "password",
      :password_confirmation => "password",
      :government_affiliation => "1"
    }
  end

  describe "when validating" do
    should_validate_presence_of :email
    should_validate_uniqueness_of :email
    should_validate_presence_of :contact_name

    should_have_and_belong_to_many :affiliates

    it "should create a new instance given valid attributes" do
      User.create!(@valid_attributes)
    end

    it "should create a user with a minimal set of attributes if the user is an affiliate" do
      developer_user = User.new(@valid_developer_attributes)
      developer_user.save.should be_true
      developer_user.is_developer?.should be_true
    end

    it "should create a user with a minimal set of attributes if the user is a developer" do
      affiliate_user = User.new(@valid_affiliate_attributes)
      affiliate_user.save.should be_true
      affiliate_user.is_developer?.should be_false
    end
    
    it "should send the admins a notification email about the new user" do
      Emailer.should_receive(:deliver_new_user_to_admin).with(an_instance_of(User))
      User.create!(@valid_attributes)
    end

    it "should send the user a welcome email" do
      Emailer.should_receive(:deliver_welcome_to_new_user).with(an_instance_of(User))
      User.create!(@valid_attributes)
    end
    
    it "should generate an API Key when creating a new user" do
      user = User.create!(@valid_attributes)
      user.api_key.should_not be_nil
    end
    
    it "should not allow duplicate API keys" do
      user = User.create!(@valid_attributes)
      User.create(@valid_attributes.merge(:api_key => user.api_key)).id.should be_nil
    end
  end

  context "when saving/updating" do
    it { should allow_mass_assignment_of(:crypted_password, :email) }
    it { should_not allow_mass_assignment_of(:is_affiliate_admin) }
    it { should_not allow_mass_assignment_of(:is_affiliate) }
    it { should_not allow_mass_assignment_of(:is_analyst) }
    it { should_not allow_mass_assignment_of(:strict_mode) }
  end

  describe "#to_label" do
    it "should return the user's contact name" do
      u = users(:affiliate_admin)
      u.to_label.should == u.contact_name
    end
  end
  
  describe "#is_developer?" do
    it "should return true when is_affiliate? and is_affiliate_admin? and is_analyst? are false" do
      users(:affiliate_admin).is_developer?.should be_false
      users(:affiliate_manager).is_developer?.should be_false
      users(:analyst).is_developer?.should be_false
      users(:developer).is_developer?.should be_true
    end
  end

  describe "when validating with strict_mode" do
    it "should require organization name, phone and address fields if strict_mode is set" do
      user = User.new(@valid_affiliate_attributes)
      user.strict_mode.should be_false
      user.should_not validate_presence_of(:phone)
      user.should_not validate_presence_of(:organization_name)
      user.should_not validate_presence_of(:address)
      user.should_not validate_presence_of(:city)
      user.should_not validate_presence_of(:state)
      user.should_not validate_presence_of(:zip)
      user.strict_mode = true
      user.should validate_presence_of(:contact_name)
      user.should validate_presence_of(:email)
      user.should validate_presence_of(:phone)
      user.should validate_presence_of(:organization_name)
      user.should validate_presence_of(:address)
      user.should validate_presence_of(:city)
      user.should validate_presence_of(:state)
      user.should validate_presence_of(:zip)
    end
  end
end
