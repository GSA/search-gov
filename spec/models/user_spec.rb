require 'spec_helper'

describe User do
  fixtures :users, :affiliates, :memberships

  let(:valid_attributes) do
    { email: "unique_login@agency.gov",
      contact_name: "Some One",
      organization_name: "Agency",
    }.freeze
  end

  before do
    @valid_affiliate_attributes = {
      email: 'some.guy@usa.gov',
      contact_name: 'Some Guy',
      organization_name: 'Agency'
    }
    @emailer = double(Emailer)
    allow(@emailer).to receive(:deliver_now).and_return true
  end

  describe 'schema' do
    it do
      is_expected.to have_db_column(:requires_manual_approval).
        of_type(:boolean).with_options(default: false)
    end

    it { should have_db_column(:uid).of_type(:string) }
  end

  describe "when validating" do
    before do
      allow_any_instance_of(User).to receive(:inviter) { users(:affiliate_manager) }
      allow_any_instance_of(User).to receive(:affiliates) { [affiliates(:basic_affiliate)] }
    end

    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:affiliates).through :memberships }

    it do
      is_expected.to validate_presence_of(:organization_name).on(:update_account)
    end

    it do
      is_expected.to validate_presence_of(:contact_name).on(:update_account)
    end

    it "should create a new instance given valid attributes" do
      User.create!(valid_attributes)
    end

    it "should create a user with a minimal set of attributes if the user is an affiliate" do
      affiliate_user = User.new(@valid_affiliate_attributes)
      expect(affiliate_user.save).to be true
      expect(affiliate_user.is_affiliate?).to be true
    end

    it "should send the admins a notification email about the new user" do
      expect(Emailer).to receive(:new_user_to_admin).with(an_instance_of(User)).and_return @emailer
      User.create!(valid_attributes)
    end

    it "should not receive welcome to new user added by affiliate" do
      expect(Emailer).to_not receive(:welcome_to_new_user_added_by_affiliate)
      User.create!(valid_attributes)
    end

    context "when the flag to not send an email is set to true" do
      it "should not send any emails" do
        User.create!(valid_attributes.merge(:skip_welcome_email => true))
      end
    end

    context 'when the user was invited' do
      let(:user) { User.new(invited: true) }

      it 'does not require an organization name' do
        user.valid?
        expect(user.errors[:organization_name]).to eq []
      end
    end
  end

  describe 'scopes' do
    let(:approved_affiliate_user) { users(:affiliate_manager) }
    let(:not_approved_user) { users(:affiliate_manager_with_not_approved_status) }
    let(:pending_user) { users(:affiliate_manager_with_pending_approval_status) }
    let(:non_affiliate) { users(:developer) }
    let(:not_active_user) { users(:not_active_user) }
    let(:active_user) { users(:active_user) }
    let(:never_active_user) { users(:never_active_user) }
    let(:new_non_active_user) { users(:new_non_active_user) }

    describe '.approved_affiliate' do
      subject(:approved_affiliate) { User.approved_affiliate }

      it { is_expected.to include(approved_affiliate_user) }
      it { is_expected.not_to include(not_approved_user) }
      it { is_expected.not_to include(non_affiliate) }
      it { is_expected.not_to include(pending_user) }
    end

    describe '.not_approved' do
      subject(:not_approved) { User.not_approved }

      let(:approved_user) { users(:affiliate_manager) }
      let(:not_approved_user) { users(:affiliate_manager_with_not_approved_status) }
      let(:pending_user) { users(:affiliate_manager_with_pending_approval_status) }

      it { is_expected.to include(not_approved_user) }
      it { is_expected.not_to include(approved_user) }
      it { is_expected.not_to include(pending_user) }
    end

    describe '.approved' do
      subject(:approved) { User.approved }

      let(:approved_user) { users(:affiliate_manager) }

      it { is_expected.to include(approved_affiliate_user) }
      it { is_expected.not_to include(pending_user) }
      it { is_expected.not_to include(not_approved_user) }
    end

    describe '.not_active' do
      subject(:not_active) { User.not_active }

      it { is_expected.to include(not_active_user) }
      it { is_expected.not_to include(active_user) }
      it { is_expected.to include(never_active_user) }
      it { is_expected.not_to include(new_non_active_user) }
    end

    describe '.not_active_since' do
      subject(:not_active_since) { User.not_active_since(76.days.ago.to_date) }

      let(:not_active_76_days_user) { users(:not_active_76_days) }
      let(:never_active_76_days_user) { users(:never_active_76_days) }

      it { is_expected.to include(not_active_76_days_user) }
      it { is_expected.to include(never_active_76_days_user) }
    end
  end

  describe '.complete?' do
    subject(:incomplete_account) { user.complete? }

    context 'when the user contact name is empty' do
      let(:user) { users(:no_contact_name) }

      it { is_expected.to eq(false) }
    end

    context 'when the user organization name is empty' do
      let(:user) { users(:no_organization_name) }

      it { is_expected.to eq(false) }
    end

    context 'when the user contact name and organization name are not empty' do
      let(:user) { users(:affiliate_manager) }

      it { is_expected.to eq(true) }
    end
  end

  describe '#has_government_affiliated_email' do
    context 'when the affiliate user is government affiliated' do
      it 'should report a government affiliated email' do
        expect(User.new(@valid_affiliate_attributes).has_government_affiliated_email?).to be_truthy
      end
    end

    context 'when the affiliate user is not government affiliated' do
      it 'should not report a government affiliated email' do
        expect(User.new(@valid_affiliate_attributes.merge(email: 'foo@bar.com')).has_government_affiliated_email?).to be_falsey
      end
    end
  end

  describe "on create" do
    it "should assign approval status" do
      user = User.create!(valid_attributes)
      expect(user.approval_status).not_to be_blank
    end

    it 'downcases the email address' do
      user = User.create!(valid_attributes.merge(email: 'Aff@agency.GOV'))
      expect(user.email).to eq('aff@agency.gov')
    end

    context 'when a user has a .gov/.mil email address' do
      let(:emails) do
        %w[aff@agency.GOV aff@anotheragency.gov admin@agency.mil anotheradmin@agency.MIL]
      end

      it 'sets the approval status to approved' do
        emails.each do |email|
          user = User.create!(@valid_affiliate_attributes.merge(email: email))
          expect(user.is_approved?).to be true
        end
      end
    end

    context 'when a user has a non gov email address' do
      let(:emails) do
        %w[aff@agency.COM aff@anotheragency.com admin.gov@agency.org anotheradmin.MIL@agency.ORG
         escape_the_dot@foo.xmil]
      end

      it 'sets the approval status to pending_approval' do
        emails.each do |email|
          user = User.create!(@valid_affiliate_attributes.merge(email: email))
          expect(user.is_pending_approval?).to be true
        end
      end
    end

    context 'when a user is an affiliate and the email is not government_affiliated' do
      let(:emails) do
        %w[aff@agency.COM aff@anotheragency.com admin.gov@agency.org
           anotheradmin.MIL@agency.ORG escape_the_dot@foo.xmil]
      end

      it 'sets requires_manual_approval' do
        emails.each do |email|
          user = User.create!(@valid_affiliate_attributes.merge(email: email))
          expect(user.requires_manual_approval?).to be true
        end
      end
    end


    it "should not set requires_manual_approval if the user is an affiliate and the email is government_affiliated" do
      %w( aff@agency.GOV aff@anotheragency.gov admin@agency.mil anotheradmin@agency.MIL ).each do |email|
        user = User.create!(@valid_affiliate_attributes.merge(:email => email))
        expect(user.requires_manual_approval?).to be false
      end
    end
  end

  context "when saving/updating" do
    it { is_expected.to allow_value("pending_approval").for(:approval_status) }
    it { is_expected.to allow_value("approved").for(:approval_status) }
    it { is_expected.to allow_value("not_approved").for(:approval_status) }

    # login.gov - commented out till SRCH-952. Updating email address will have a different flow.
    pending 'when updating an email address' do
      let(:user) { users(:affiliate_admin) }
      let(:new_email) { 'new@new.gov' }
      subject(:update_email) { user.update(email: new_email) }

      context 'to a non-government address' do
        let(:new_email) { 'random@random.com' }
        it 'requires approval' do
          expect{ update_email }.
            to change{ user.reload.requires_manual_approval }.from(false).to(true)
        end
      end

      context 'to a government address' do
        let(:user) { users(:affiliate_requiring_manual_approval) }
        let(:new_email) { 'new@new.gov' }

        it 'does not require approval' do
          expect{ update_email }.to change{ user.reload.requires_manual_approval }.from(true).to(false)
        end
      end
    end
  end

  describe "#to_label" do
    it "should return the user's contact name" do
      u = users(:affiliate_admin)
      expect(u.to_label).to eq('Affiliate Administrator <affiliate_admin@fixtures.org>')
    end
  end

  describe "#is_developer?" do
    it "should return true when is_affiliate? and is_affiliate_admin? are false" do
      expect(users(:affiliate_admin).is_developer?).to be false
      expect(users(:affiliate_manager).is_developer?).to be false
      expect(users(:developer).is_developer?).to be true
    end
  end

  describe "#has_government_affiliated_email?" do
    it "should return true if the e-mail address ends with .gov or .mil" do
      %w(aff@agency.GOV aff@anotheragency.gov admin@agency.mil anotheradmin@agency.MIL).each do |email|
        user = User.new(@valid_affiliate_attributes.merge({ :email => email }))
        expect(user.has_government_affiliated_email?).to be_truthy
      end
    end

    it 'should return true if the email address ends with .fed.us' do
      user = User.new(@valid_affiliate_attributes.merge({ email: 'user@fs.fed.US' }))
      expect(user).to be_has_government_affiliated_email
    end

    it 'should return true if the email address ends with state.*.us' do
      %w(user@co.franklin.state.dc.US user@state.dc.US).each do |email|
        user = User.new(@valid_affiliate_attributes.merge({ email: email }))
        expect(user).to be_has_government_affiliated_email
      end
    end

    it "should return false if the e-mail adresses do not match" do
      %w(user@affiliate@corp.com user@FSRFED.us user@fs.fed.usa user@co.franklin.state.kids.us user@lincoln.k12.oh.us user@co.state.z.us).each do |email|
        expect(User.new(@valid_affiliate_attributes.merge({ email: email }))).not_to be_has_government_affiliated_email
      end
    end
  end

  describe "#send_new_affiliate_user_email" do
    let(:inviter) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }

    before do
      @user = users(:marilyn)
    end

    it "sends the 'new_affiliate_user' email" do
      expect(Emailer).to receive(:new_affiliate_user).with(affiliate, @user, inviter).and_return @emailer

      @user.send_new_affiliate_user_email(affiliate, inviter)
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
        expect(Emailer).to receive(:welcome_to_new_user).with(an_instance_of(User)).and_return @emailer
        @user.save!
      end

      it "should update welcome_email_sent to true" do
        @user.save!
        expect(@user.welcome_email_sent?).to be true
      end
    end

    context "when welcome_email_sent is true" do
      before do
        @user.set_approval_status_to_approved
        @user.welcome_email_sent = true
      end

      it "should not deliver welcome email" do
        expect(Emailer).to_not receive(:welcome_to_new_user).with(an_instance_of(User))
        @user.save!
      end
    end
  end

  describe '#new_invited_by_affiliate' do
    let(:inviter) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }

    context 'when contact_name and email are provided' do

      it 'initializes new user with assign affiliate, contact_name, and email' do
        new_user = User.new_invited_by_affiliate(inviter,
                                                 affiliate,
                                                 { contact_name: 'New User Name',
                                                   email: 'newuser@approvedagency.com' })
        new_user.save!
        expect(new_user.affiliates.first).to eq(affiliate)
        expect(new_user.contact_name).to eq('New User Name')
        expect(new_user.email).to eq('newuser@approvedagency.com')
        expect(new_user.is_affiliate?).to be true
        expect(new_user.requires_manual_approval).to be false
        expect(new_user.is_approved?).to be true
        expect(new_user.welcome_email_sent).to be false
        expect(affiliate.users).to include(new_user)
      end

      it 'receives the welcome new user' do
        expect(Emailer).to receive(:welcome_to_new_user_added_by_affiliate).and_return @emailer
        new_user = User.new_invited_by_affiliate(inviter,
                                                 affiliate,
                                                 { contact_name: 'New User Name',
                                                   email: 'newuser@approvedagency.com' })
        new_user.save!
      end
    end
  end

  describe "#affiliate_names" do
    before do
      @user = users(:affiliate_manager_with_no_affiliates)
    end

    it "returns all associated affiliate display names" do
      affiliates(:power_affiliate).users << @user
      affiliates(:basic_affiliate).users << @user
      expect(@user.affiliate_names.split(',').sort).to eq(%w{ noaa.gov nps.gov })
    end

    it "returns blank if there is no associated affiliate" do
      expect(@user.affiliate_names).to eq('')
    end
  end

  describe '#add_to_affiliate' do
    let(:user) { users('affiliate_manager') }
    let(:site) { affiliates(:another_affiliate) }

    subject(:add_to_affiliate) { user.add_to_affiliate(site, 'Someone') }

    before do
      expect(Rails.logger).to receive(:info).with(
        "Someone added User #{user.id}, affiliate_manager@fixtures.org,
        to Affiliate #{site.id}, Another Gov Site [another.gov].".squish
      )
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
      expect(Rails.logger).to receive(:info).with(
        "Someone removed User #{user.id}, affiliate_manager@fixtures.org,
        from Affiliate #{site.id}, NPS Site [nps.gov].".squish
      )
    end

    it 'removes the user from the site' do
      remove_from_affiliate
      expect(site.users).not_to include(user)
    end
  end

  describe '.from_omniauth' do
    let(:auth) { mock_user_auth('foo@gsa.gov', '55555') }

    subject(:from_omniauth) { User.from_omniauth(auth) }

    it { is_expected.to be_a_kind_of(User) }

    context 'when the user is new' do
      it 'sets the uid' do
        expect(from_omniauth.uid).to(eq '55555')
      end
    end

    context 'when existing user no uid' do
      let(:auth) { mock_user_auth('user_without_uid@fixtures.org', '22222') }
      let(:user) { users(:user_without_uid) }

      it 'sets the uid' do
        expect(from_omniauth.uid).to eq '22222'
      end
    end
  end
end
