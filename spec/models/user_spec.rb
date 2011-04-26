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
    should_validate_acceptance_of :terms_of_service

    should_have_and_belong_to_many :affiliates

    it "should create a new instance given valid attributes" do
      User.create!(@valid_attributes)
    end

    it "should create a user with a minimal set of attributes if the user is a developer" do
      developer_user = User.new(@valid_developer_attributes)
      developer_user.save.should be_true
      developer_user.is_developer?.should be_true
    end

    it "should create a user with a minimal set of attributes if the user is a developer with .com email address" do
      developer_user = User.new(@valid_developer_attributes.merge(:email => 'not.gov.user@agency.com'))
      developer_user.save.should be_true
      developer_user.is_developer?.should be_true
     end

    it "should create a user with a minimal set of attributes if the user is an affiliate" do
      affiliate_user = User.new(@valid_affiliate_attributes)
      affiliate_user.save.should be_true
      affiliate_user.is_affiliate?.should be_true
    end

    it "should send the admins a notification email about the new user" do
      Emailer.should_receive(:deliver_new_user_to_admin).with(an_instance_of(User))
      User.create!(@valid_attributes)
    end

    it "should send email verification to user with .gov or .mil email address" do
      Emailer.should_receive(:deliver_new_user_email_verification).with(an_instance_of(User))
      User.create!(@valid_attributes)
    end

    it "should not send email verification to user without .gov or .mil email address" do
      Emailer.should_not_receive(:deliver_new_user_email_verification).with(an_instance_of(User))
      User.create!(@valid_attributes.merge(:email => 'not.gov@agency.com'))
    end

    context "when the user is a developer" do
      it "should send the developer a welcome email" do
        Emailer.should_receive(:deliver_welcome_to_new_developer).with(an_instance_of(User))
        User.create!(@valid_developer_attributes)
      end
    end

    context "when the flag to not send an email is set to true" do
      it "should not send any emails" do
        Emailer.should_not_receive(:deliver_welcome_to_new_developer)
        User.create!(@valid_attributes.merge(:skip_welcome_email => true))
      end
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

  describe "on create" do
    it "should assign approval status" do
      user = User.create!(@valid_attributes)
      user.approval_status.should_not be_blank
    end

    it "should set approval status to pending_email_verification if the affiliate user is government affiliated" do
      %w( aff@agency.GOV aff@anotheragency.gov admin@agency.mil anotheradmin@agency.MIL ).each do |email|
        user = User.create!(@valid_affiliate_attributes.merge({:email => email}))
        user.has_government_affiliated_email?.should be_true
        user.is_pending_email_verification?.should be_true
      end
    end

    it "should set approval status to pending_contact_information if the affiliate user is not  government_affiliated" do
      %w( aff@agency.COM aff@anotheragency.com admin.gov@agency.org anotheradmin.MIL@agency.ORG escape_the_dot@foo.xmil ).each do |email|
        user = User.create!(@valid_affiliate_attributes.merge({:email => email}))
        user.has_government_affiliated_email?.should be_false
        user.is_pending_contact_information?.should be_true
      end
    end

    it "should set approval status to approved if the user is a developer" do
      %w( aff@agency.GOV aff@anotheragency.gov admin@agency.mil anotheradmin@agency.MIL aff@agency.COM aff@anotheragency.com admin.gov@agency.org anotheradmin.MIL@agency.ORG escape_the_dot@foo.xmil ).each do |email|
        developer_user = User.create!(@valid_developer_attributes.merge(:email => email))
        developer_user.is_approved?.should be_true
      end
    end

    it "should not set requires_manual_approval if the user is an affiliate and the email is government_affiliated" do
      %w( aff@agency.GOV aff@anotheragency.gov admin@agency.mil anotheradmin@agency.MIL ).each do |email|
        user = User.create!(@valid_affiliate_attributes.merge(:email => email))
        user.requires_manual_approval?.should be_false
      end
    end

    it "should set requires_manual_approval if the user is an affiliate and the email is not government_affiliated" do
      %w( aff@agency.COM aff@anotheragency.com admin.gov@agency.org anotheradmin.MIL@agency.ORG escape_the_dot@foo.xmil ).each do |email|
        user = User.create!(@valid_affiliate_attributes.merge(:email => email))
        user.requires_manual_approval?.should be_true
      end
    end

    it "should set requires_manual_approval to false if the user is a developer" do
      %w( aff@agency.GOV aff@anotheragency.gov admin@agency.mil anotheradmin@agency.MIL aff@agency.COM aff@anotheragency.com admin.gov@agency.org anotheradmin.MIL@agency.ORG escape_the_dot@foo.xmil ).each do |email|
        developer_user = User.create!(@valid_developer_attributes.merge(:email => email))
        developer_user.requires_manual_approval?.should be_false
      end
    end

    it "should set email_verification_token if the user is pending_email_verification" do
      user = User.create!(@valid_affiliate_attributes)
      user.is_pending_email_verification?.should be_true
      user.email_verification_token.should_not be_blank
    end
  end

  context "when saving/updating" do
    it { should allow_mass_assignment_of(:crypted_password, :email) }
    it { should_not allow_mass_assignment_of(:is_affiliate_admin) }
    it { should_not allow_mass_assignment_of(:is_affiliate) }
    it { should_not allow_mass_assignment_of(:is_analyst) }
    it { should_not allow_mass_assignment_of(:strict_mode) }
    it { should_not allow_mass_assignment_of(:approval_status) }
    it { should_not allow_mass_assignment_of(:requires_manual_approval) }
    it { should_not allow_mass_assignment_of(:welcome_email_sent) }
    it { should validate_inclusion_of :approval_status, :in => %w( pending_email_verification pending_approval approved not_approved ) }
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

  describe "#is_government_affiliated?" do
    it "should return true if the e-mail address ends with .gov or .mil" do
      %w(aff@agency.GOV aff@anotheragency.gov admin@agency.mil anotheradmin@agency.MIL).each do |email|
        user = User.new(@valid_affiliate_attributes.merge({:email => email}))
        user.has_government_affiliated_email?.should be_true
      end
    end

    it "should return false if the e-mail adress does not end with .gov or .mil" do
      user = User.new(@valid_affiliate_attributes.merge({:email => 'affiliate@corp.com'}))
      user.has_government_affiliated_email?.should be_false
      user = User.new(@valid_affiliate_attributes.merge({:email => nil}))
      user.has_government_affiliated_email?.should be_false
    end
  end

  describe "#verify_email" do
    context "has matching email verification token and does not require manual approval" do
      before do
        @user = User.create!(@valid_affiliate_attributes.merge(:email => 'user@agency.gov'))
        @user.is_pending_email_verification?.should be_true
        @user.welcome_email_sent?.should be_false
        @user.verify_email(@user.email_verification_token).should be_true
      end

      it "should update the approval_status to approved" do
        @user.is_approved?.should be_true
      end

      it "should update welcome_email_sent flag to true" do
        @user.welcome_email_sent?.should be_true
      end
    end

    context "has matching email verification token and requires manual approval" do
      before do
        @user = User.create!(@valid_affiliate_attributes.merge(:email => 'not.gov@agency.com'))
        @user.strict_mode = true
        @user.update_attributes(@valid_attributes.merge(:email => 'not.gov@agency.com'))
        @user.is_pending_email_verification?.should be_true
        @user = User.find_by_email('not.gov@agency.com')
        @user.welcome_email_sent?.should be_false
        @user.verify_email(@user.email_verification_token).should be_true
      end

      it "should update the approval_status to pending_approval" do
        @user.is_pending_approval?.should be_true
      end

      it "should not update the welcome_email_sent flag" do
        @user.welcome_email_sent?.should be_false
      end
    end

    it "should return true if the user is already approved" do
      user = users(:affiliate_manager)
      user.is_approved?.should be_true
      user.verify_email('any token').should be_true
    end

    it "should return false if the user does not have matching email_verification_token" do
      user = users(:affiliate_manager_with_pending_email_verification_status)
      user.verify_email('mismatched token').should be_false
    end
  end

  describe "on update in strict_mode and pending_contact_information status" do
    before do
      @user = User.create!(:email => 'not.gov@agency.com', :contact_name => 'affiliate manager', :password => 'super secret', :password_confirmation => 'super secret', :government_affiliation => "1")
      @user.strict_mode = true
      @user.is_pending_contact_information?.should be_true
    end

    context "when it updates attributes successfully" do
      before do
        @update_attributes = {
            :organization_name => "Agency",
            :phone=> "301-123-4567",
            :address=> "123 Penn Ave",
            :address2=> "Ste 100",
            :city=> "Reston",
            :state=> "VA",
            :zip=> "20022"
        }
        @user.update_attributes(@update_attributes).should be_true
      end

      it "should update the user approval status to pending_email_verification" do
        @user.is_pending_email_verification?.should be_true
      end

      it "should set the email_verification_token" do
        @user.email_verification_token.should_not be_blank
      end
    end

    context "when it fails to update attributes" do
      before do
        @user.update_attributes({}).should be_false
      end

      it "should not update the approval status" do
        @user.is_pending_contact_information?.should be_true
      end

      it "should not set email_verification_token" do
        @user.email_verification_token.should be_blank
      end
    end
  end

  describe "on update from pending_approval to approved" do
    before do
      @user = users(:affiliate_manager_with_pending_approval_status)
    end

    context "when welcome_email_sent is false" do
      before do
        @user.set_approval_status_to_approved
      end

      it "should deliver welcome email" do
        Emailer.should_receive(:deliver_welcome_to_new_user).with(an_instance_of(User))
        @user.save!
      end

      it "should update welcome_email_sent to true" do
        @user.save!
        @user.welcome_email_sent?.should be_true
      end
    end

    context "when welcome_email_sent is true" do
      before do
        @user.set_approval_status_to_approved
        @user.welcome_email_sent = true
      end

      it "should not deliver welcome email" do
        Emailer.should_not_receive(:deliver_welcome_to_new_user).with(an_instance_of(User))
        @user.save!
      end
    end
  end
end
