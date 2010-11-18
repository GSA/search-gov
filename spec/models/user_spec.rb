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
    @valid_developer_attributes = {
      :email => "some.guy@usa.gov",
      :contact_name => "Some Guy",
      :password => "password",
      :password_confirmation => "password"
    }
  end

  describe "when validating" do
    should_validate_presence_of :email
    should_validate_uniqueness_of :email
    should_validate_presence_of :phone, :if => :is_affiliate_or_higher
    should_validate_presence_of :zip, :if => :is_affiliate_or_higher
    should_validate_presence_of :organization_name, :if => :is_affiliate_or_higher
    should_validate_presence_of :address, :if => :is_affiliate_or_higher
    should_validate_presence_of :state, :if => :is_affiliate_or_higher
    should_validate_presence_of :time_zone, :if => :is_affiliate_or_higher
    should_validate_presence_of :contact_name
    
    should_have_and_belong_to_many :affiliates

    it "should create a new instance given valid attributes" do
      User.create(@valid_attributes)
    end
    
    it "should create a user with a minimal set of attributes if the user is a developer" do
      developer_user = User.new(@valid_developer_attributes)
      developer_user.is_affiliate = false
      developer_user.save.should be_true
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
  end

  context "when saving/updating" do
    it { should allow_mass_assignment_of(:crypted_password, :email) }
    it { should_not allow_mass_assignment_of(:is_affiliate_admin) }
    it { should_not allow_mass_assignment_of(:is_affiliate) }
    it { should_not allow_mass_assignment_of(:is_analyst) }
  end

  describe "#to_label" do
    it "should return the user's contact name" do
      u = users(:affiliate_admin)
      u.to_label.should == u.contact_name
    end
  end
  
  describe "#new_developer" do
    it "should return a User with no affiliate, affiliate_admin or analyst privileges" do
      developer = User.new_developer
      developer.is_affiliate.should be_false
      developer.is_affiliate_admin.should be_false
      developer.is_analyst.should be_false
    end
  end
end