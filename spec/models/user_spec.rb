require 'spec_helper'

describe User do
  fixtures :users, :affiliates, :memberships

  let(:adapter) { mock(NutshellAdapter) }
  let(:mandrill_user_emailer) { mock(MandrillUserEmailer) }

  before do
    @valid_attributes = {
        :email => "unique_login@agency.gov",
        :password => "password",
        :contact_name => "Some One",
        :organization_name => "Agency"
    }

    @valid_affiliate_attributes = {
        :email => "some.guy@usa.gov",
        :contact_name => "Some Guy",
        :password => "password"
    }
    @emailer = mock(Emailer)
    @emailer.stub!(:deliver).and_return true

    NutshellAdapter.stub(:new) { adapter }

    MandrillUserEmailer.stub(:new).with(an_instance_of(User)).and_return(mandrill_user_emailer)
    mandrill_user_emailer.stub(:send_new_affiliate_user)
    mandrill_user_emailer.stub(:send_new_user_email_verification)
    mandrill_user_emailer.stub(:send_password_reset_instructions)
    mandrill_user_emailer.stub(:send_welcome_to_new_user)
    mandrill_user_emailer.stub(:send_welcome_to_new_user_added_by_affiliate)
  end

  describe 'schema' do
    it { should have_db_column(:failed_login_count).of_type(:integer).with_options(default: 0, null: false) }
  end

  describe "when validating" do
    before do
      adapter.stub(:push_user)
      User.any_instance.stub(:email_verification_token) { 'e_v_token' }
      User.any_instance.stub(:inviter) { users(:affiliate_manager) }
      User.any_instance.stub(:affiliates) { [affiliates(:basic_affiliate)] }
    end

    it { should validate_presence_of :email }
    it { should validate_uniqueness_of :email }
    it { should validate_presence_of :contact_name }
    it { should have_many(:memberships).dependent(:destroy) }
    it { should have_many(:affiliates).through :memberships }

    it "should create a new instance given valid attributes" do
      User.create!(@valid_attributes)
    end

    it "should create a user with a minimal set of attributes if the user is an affiliate" do
      affiliate_user = User.new(@valid_affiliate_attributes)
      affiliate_user.save.should be_true
      affiliate_user.is_affiliate?.should be_true
    end

    it "should send the admins a notification email about the new user" do
      Emailer.should_receive(:new_user_to_admin).with(an_instance_of(User)).and_return @emailer
      User.create!(@valid_attributes)
    end

    it "should send email verification to user" do
      mandrill_user_emailer.should_receive(:send_new_user_email_verification)
      User.create!(@valid_attributes)
    end

    it "should not receive welcome to new user added by affiliate" do
      mandrill_user_emailer.should_not_receive(:send_welcome_to_new_user_added_by_affiliate)
      User.create!(@valid_attributes)
    end

    context "when the flag to not send an email is set to true" do
      it "should not send any emails" do
        User.create!(@valid_attributes.merge(:skip_welcome_email => true))
      end
    end
  end

  describe '#deliver_password_reset_instructions!' do
    subject(:user) { User.create!(@valid_attributes.merge(perishable_token: original_token)) }

    before do
      Authlogic::Random.stub(:friendly_token).and_return(random_new_token)
      adapter.stub(:push_user)
    end

    let(:original_token) { 'original_perishable_token_that_should_change' }
    let(:random_new_token) { 'something_random_the_token_should_change_to' }

    it "resets the user's perishable token" do
      user.deliver_password_reset_instructions!
      user.perishable_token.should eq(random_new_token)
    end

    it 'sends the password_reset_instructions template via mandrill' do
      mandrill_user_emailer.should_receive(:send_password_reset_instructions)
      user.deliver_password_reset_instructions!
    end
  end

  describe '#has_government_affiliated_email' do
    context 'when the affiliate user is government affiliated' do
      it 'should report a government affiliated email' do
        User.new(@valid_affiliate_attributes).has_government_affiliated_email?.should be_true
      end
    end

    context 'when the affiliate user is not government affiliated' do
      it 'should not report a government affiliated email' do
        User.new(@valid_affiliate_attributes.merge(email: 'foo@bar.com')).has_government_affiliated_email?.should be_false
      end
    end
  end

  describe "on create" do
    before { adapter.stub(:push_user) }

    it "should assign approval status" do
      user = User.create!(@valid_attributes)
      user.approval_status.should_not be_blank
    end

    it 'downcases the email address' do
      user = User.create!(@valid_attributes.merge(email: 'Aff@agency.GOV'))
      user.email.should == 'aff@agency.gov'
    end

    it "should set approval status to pending_email_verification" do
      %w( aff@agency.GOV aff@anotheragency.gov admin@agency.mil anotheradmin@agency.MIL aff@agency.COM aff@anotheragency.com admin.gov@agency.org anotheradmin.MIL@agency.ORG escape_the_dot@foo.xmil ).each do |email|
        user = User.create!(@valid_affiliate_attributes.merge(email: email))
        user.is_pending_email_verification?.should be_true
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

    it "should set email_verification_token if the user is pending_email_verification" do
      user = User.create!(@valid_affiliate_attributes)
      user.is_pending_email_verification?.should be_true
      user.email_verification_token.should_not be_blank
    end

    context "when the same email_verification_token as another user is generated" do
      let(:user) { User.new(@valid_attributes).tap { |u| puts u.inspect } }
      let(:token) { 'unique token' }

      before do
        existing_user = users(:affiliate_manager_with_pending_contact_information_status)
        Authlogic::Random.stub(:friendly_token).and_return(
          'salt_for_user_password',                # for the initial User.new
          existing_user.email_verification_token,  # induces uniqueness error
          token                                    # final value works because it's unique
        )
      end

      it "doesn't raise the uniqueness constraint violation error" do
        expect { user.save(@valid_attributes)}.to_not raise_error
      end

      it "assigns a new email_verification_token" do
        user.save
        user.email_verification_token.should == token
      end
    end
  end

  context "when saving/updating" do
    it { should allow_mass_assignment_of(:crypted_password) }
    it { should allow_mass_assignment_of(:email) }
    it { should_not allow_mass_assignment_of(:is_affiliate_admin) }
    it { should_not allow_mass_assignment_of(:is_affiliate) }
    it { should_not allow_mass_assignment_of(:approval_status) }
    it { should_not allow_mass_assignment_of(:requires_manual_approval) }
    it { should_not allow_mass_assignment_of(:welcome_email_sent) }
    it { should allow_value("pending_email_verification").for(:approval_status) }
    it { should allow_value("pending_approval").for(:approval_status) }
    it { should allow_value("approved").for(:approval_status) }
    it { should allow_value("not_approved").for(:approval_status) }
  end

  describe "#to_label" do
    it "should return the user's contact name" do
      u = users(:affiliate_admin)
      u.to_label.should == 'Affiliate Administrator <affiliate_admin@fixtures.org>'
    end
  end

  describe "#is_developer?" do
    it "should return true when is_affiliate? and is_affiliate_admin? are false" do
      users(:affiliate_admin).is_developer?.should be_false
      users(:affiliate_manager).is_developer?.should be_false
      users(:developer).is_developer?.should be_true
    end
  end

  describe "#has_government_affiliated_email?" do
    it "should return true if the e-mail address ends with .gov or .mil" do
      %w(aff@agency.GOV aff@anotheragency.gov admin@agency.mil anotheradmin@agency.MIL).each do |email|
        user = User.new(@valid_affiliate_attributes.merge({ :email => email }))
        user.has_government_affiliated_email?.should be_true
      end
    end

    it 'should return true if the email address ends with .fed.us' do
      user = User.new(@valid_affiliate_attributes.merge({ email: 'user@fs.fed.US' }))
      user.should be_has_government_affiliated_email
    end

    it 'should return true if the email address ends with state.*.us' do
      %w(user@co.franklin.state.dc.US user@state.dc.US).each do |email|
        user = User.new(@valid_affiliate_attributes.merge({ email: email }))
        user.should be_has_government_affiliated_email
      end
    end

    it "should return false if the e-mail adresses do not match" do
      %w(user@affiliate@corp.com user@FSRFED.us user@fs.fed.usa user@co.franklin.state.kids.us user@lincoln.k12.oh.us user@co.state.z.us).each do |email|
        User.new(@valid_affiliate_attributes.merge({ email: email })).should_not be_has_government_affiliated_email
      end
    end
  end

  describe "#verify_email" do
    context "has matching email verification token and does not require manual approval" do
      before do
        adapter.should_receive(:push_user).twice
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
        adapter.should_receive(:push_user).exactly(3).times
        @user = User.create!(@valid_affiliate_attributes.merge(:email => 'not.gov@agency.com'))
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

  describe "#send_new_affiliate_user_email" do
    let(:inviter) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }

    before do
      @user = users(:marilyn)
    end

    it "sends the 'new_affiliate_user' email via Mandrill with the right merge fields" do
      mandrill_user_emailer.should_receive(:send_new_affiliate_user).with(affiliate, inviter)

      @user.send_new_affiliate_user_email(affiliate, inviter)
    end
  end

  describe "on update from pending_approval to approved" do
    before do
      @user = users(:affiliate_manager_with_pending_approval_status)
    end

    context "when welcome_email_sent is false" do
      before do
        adapter.should_receive(:push_user).with(@user)
        @user.set_approval_status_to_approved
      end

      it "should deliver welcome email" do
        mandrill_user_emailer.should_receive(:send_welcome_to_new_user)
        @user.save!
      end

      it "should update welcome_email_sent to true" do
        @user.save!
        @user.welcome_email_sent?.should be_true
      end
    end

    context "when welcome_email_sent is true" do
      before do
        adapter.should_receive(:push_user).with(@user)
        @user.set_approval_status_to_approved
        @user.welcome_email_sent = true
      end

      it "should not deliver welcome email" do
        mandrill_user_emailer.should_not_receive(:send_welcome_to_new_user)
        @user.save!
      end
    end
  end

  describe "#new_invited_by_affiliate" do
    let(:inviter) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }

    context "when contact_name and email are provided" do

      it "should initialize new user with assign affiliate, contact_name, and email" do
        adapter.should_receive(:push_user)
        new_user = User.new_invited_by_affiliate(inviter, affiliate, { :contact_name => 'New User Name', :email => 'newuser@approvedagency.com' })
        new_user.save!
        new_user.affiliates.first.should == affiliate
        new_user.contact_name.should == 'New User Name'
        new_user.email.should == 'newuser@approvedagency.com'
        new_user.is_affiliate?.should be_true
        new_user.requires_manual_approval.should be_false
        new_user.is_pending_email_verification?.should be_true
        new_user.welcome_email_sent.should be_false
        affiliate.users.should include(new_user)
      end

      it "should receive welcome new user added by affiliate email verification" do
        new_user = User.new_invited_by_affiliate(inviter, affiliate, { :contact_name => 'New User Name', :email => 'newuser@approvedagency.com' })
        mandrill_user_emailer.should_receive(:send_welcome_to_new_user_added_by_affiliate)
        mandrill_user_emailer.should_not_receive(:send_new_user_email_verification)
        adapter.should_receive(:push_user)
        new_user.save!
        new_user.email_verification_token.should_not be_blank
      end
    end
  end

  describe "#complete_registration" do
    let(:inviter) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }

    before do
      @user = User.new_invited_by_affiliate(inviter, affiliate, { :contact_name => 'New User Name', :email => 'newuser@approvedagency.com' })
      adapter.should_receive(:push_user).with(@user)
      @user.save!
    end

    context "when executed" do
      let(:user) { user = User.find @user.id }

      before do
        user.should_receive(:update_attributes)
        mandrill_user_emailer.should_not_receive(:send_welcome_to_new_user)
        user.complete_registration({})
      end

      it { user.should be_require_password }
      it { user.should be_is_approved }
      it "should set email_verification_token to nil" do
        user.email_verification_token.should be_nil
      end
    end

    context 'when password is blank' do
      let(:user) { user = User.find @user.id }
      specify { user.complete_registration({ password: '' }).should be_false }
    end
  end

  describe "#affiliate_names" do
    before do
      @user = users(:affiliate_manager_with_no_affiliates)
    end

    it "returns all associated affiliate display names" do
      affiliates(:power_affiliate).users << @user
      affiliates(:basic_affiliate).users << @user
      @user.affiliate_names.split(',').sort.should == %w{ noaa.gov nps.gov }
    end

    it "returns blank if there is no associated affiliate" do
      @user.affiliate_names.should == ''
    end
  end

  describe '#nutshell_approval_status' do
    let(:nutshell_id) { 42 }

    before do
      adapter.stub(:push_user)

      @user = User.create!(@valid_attributes.merge(nutshell_id: nutshell_id))

      approval_statuses.each do |approval_status|
        user = User.create!(@valid_attributes.merge(email: "user-#{approval_status}@example.com",
                                                    nutshell_id: nutshell_id))
        user.approval_status = approval_status
        user.save!
      end
    end

    context 'when an approved user with the same nutshell contact exists' do
      let(:approval_statuses) { ['approved'] }

      it 'should be approved' do
        @user.nutshell_approval_status.should == 'approved'
      end
    end

    context 'when a non-approved user with the same nutshell contact exists' do
      let(:approval_statuses) { ['not_approved'] }

      it 'should be the conventional user approval_status' do
        @user.nutshell_approval_status.should == 'pending_email_verification'
      end
    end

    context 'when approved and non-approved users with the same nutshell contact exist' do
      let(:approval_statuses) { ['approved', 'not_approved'] }

      it 'should be approved' do
        @user.nutshell_approval_status.should == 'approved'
      end
    end
  end

  describe '#add_to_affiliate' do
    let(:user) { users('affiliate_manager') }
    let(:site) { affiliates(:another_affiliate) }

    subject(:add_to_affiliate) { user.add_to_affiliate(site, 'Someone') }

    before do
      site.update_attribute(:nutshell_id, 100)
      adapter.should_receive(:push_site).with(site)
      adapter.should_receive(:new_note).with(user, "Someone added @[Contacts:1001], affiliate_manager@fixtures.org to @[Leads:100] Another Gov Site [another.gov].")
    end

    it 'adds the user to the site' do
      add_to_affiliate
      expect(site.users).to include(user)
    end
  end

  describe '#remove_from_affiliate' do
    let(:user) { users('affiliate_manager') }
    let(:site) { affiliates(:basic_affiliate) }

    subject(:remove_from_affiliate) { user.remove_from_affiliate(site, 'Someone') }

    before do
      adapter.should_receive(:push_site).with(site)
      adapter.should_receive(:new_note).with(user, "Someone removed @[Contacts:1001], affiliate_manager@fixtures.org from @[Leads:99] NPS Site [nps.gov].")
    end

    it 'removes the user from the site' do
      remove_from_affiliate
      expect(site.users).not_to include(user)
    end
  end
end
