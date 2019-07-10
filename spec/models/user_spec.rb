require 'spec_helper'

describe User do
  fixtures :users, :affiliates, :memberships

  let(:valid_attributes) do
    { email: "unique_login@agency.gov",
      password: "password1!",
      contact_name: "Some One",
      organization_name: "Agency",
    }.freeze
  end

  before do
    @valid_affiliate_attributes = {
        :email => "some.guy@usa.gov",
        :contact_name => "Some Guy",
        :password => "password1!",
        :organization_name => "Agency",
    }
    @emailer = double(Emailer)
    allow(@emailer).to receive(:deliver_now).and_return true
  end

  describe 'schema' do
    it { is_expected.to have_db_column(:failed_login_count).of_type(:integer).with_options(default: 0, null: false) }
    it { is_expected.to have_db_column(:password_updated_at).of_type(:datetime).with_options(null: true) }
  end

  describe "when validating" do
    before do
      allow_any_instance_of(User).to receive(:email_verification_token) { 'e_v_token' }
      allow_any_instance_of(User).to receive(:inviter) { users(:affiliate_manager) }
      allow_any_instance_of(User).to receive(:affiliates) { [affiliates(:basic_affiliate)] }
    end

    it { is_expected.to validate_presence_of :email }
    it { is_expected.to validate_uniqueness_of(:email).case_insensitive }
    it { is_expected.to validate_length_of(:password).is_at_least(8) }
    it { is_expected.to validate_presence_of :contact_name }
    it { is_expected.to have_many(:memberships).dependent(:destroy) }
    it { is_expected.to have_many(:affiliates).through :memberships }

    it 'rejects passwords without at least one letter/number/symbol' do
      %w( password 12345678 !@@#$%^&* test1234 a1! ).each do |password|
        user = User.new(password: password)
        user.valid?
        expect(user.errors[:password][0]).to match /must include a combination of letters/
      end
    end

    it 'allows passwords with at least one letter/number/symbol' do
      %w( password1! P?12345678 TesT1234! PW1!@#$%^*& ).each do |password|
        user = User.new(valid_attributes.merge(password: password))
        expect(user).to be_valid
      end
    end

    it 'requires an organization name' do
      user = User.new
      user.valid?
      expect(user.errors.full_messages).to include("Federal government agency can't be blank")
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

    it "should send email verification to user" do
      expect(Emailer).to receive(:user_email_verification).with(an_instance_of(User)).and_return @emailer

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

    context 'when updating a password' do
      let(:user) { User.create!(valid_attributes.merge(password: 'goodpass1!')) }

      context 'when password confirmation is not required' do
        before { user.update(password: 'newpass123!') }

        it 'updates the password' do
          expect(user.valid_password?('newpass123!')).to be true
        end
      end

      context 'when password confirmation is required' do
        before { user.require_password_confirmation = true }

        context 'when the current password is correct' do

          context 'when the new password is different from the current password' do
            before { user.update!(password: 'newpass123!', current_password: 'goodpass1!') }

            it 'updates the password' do
              expect(user.valid_password?('newpass123!')).to be true
            end
          end

          context 'when the new password is the same as the current password' do
            before { user.update(password: 'goodpass1!', current_password: 'goodpass1!') }

            it 'fails' do
              expect(user.errors[:password]).to eq ['is invalid: new password must be different from current password']
            end
          end
        end

        context 'when the current password is incorrect' do
          before { user.update(password: 'newpass123!', current_password: 'foobar123!') }

          it 'fails' do
            expect(user.errors[:current_password]).to eq ['is invalid']
          end
        end

        context 'when the current password is not provided' do
          before { user.update(password: 'newpass123!') }

          it 'fails' do
            expect(user.errors[:current_password]).to eq ['is invalid']
          end
        end
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
  end

  describe '#deliver_password_reset_instructions!' do
    let(:user) { User.create!(valid_attributes.merge(perishable_token: original_token)) }

    before do
      allow(Authlogic::Random).to receive(:friendly_token).and_return(random_new_token)
    end

    let(:original_token) { 'original_perishable_token_that_should_change' }
    let(:random_new_token) { 'something_random_the_token_should_change_to' }

    it "does not reset the user's perishable token" do
      expect{ user.deliver_password_reset_instructions! }.
        not_to change{ user.perishable_token }
    end

    context 'when the user has no perishable token' do
      let(:user) { User.create!(valid_attributes.merge(perishable_token: nil)) }

      it "sets the user's perishable token" do
        expect{ user.deliver_password_reset_instructions! }.
          to change{ user.perishable_token }.from(nil).to(random_new_token)
      end
    end

    context 'when the perishable token is expired' do
      #yes, the expiration is based on updated_at...blame authlogic
      before { user.update_attribute(:updated_at, 2.hours.ago) }

      it 'resets the token' do
        expect{ user.deliver_password_reset_instructions! }.
          to change{ user.perishable_token }.from(original_token).to(random_new_token)
      end
    end

    it 'sends the password_reset_instructions email' do
      expect(Emailer).to receive(:password_reset_instructions).and_return(@emailer)
      user.deliver_password_reset_instructions!
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

    it "should set approval status to pending_email_verification" do
      %w( aff@agency.GOV aff@anotheragency.gov admin@agency.mil anotheradmin@agency.MIL aff@agency.COM aff@anotheragency.com admin.gov@agency.org anotheradmin.MIL@agency.ORG escape_the_dot@foo.xmil ).each do |email|
        user = User.create!(@valid_affiliate_attributes.merge(email: email))
        expect(user.is_pending_email_verification?).to be true
      end
    end

    it "should not set requires_manual_approval if the user is an affiliate and the email is government_affiliated" do
      %w( aff@agency.GOV aff@anotheragency.gov admin@agency.mil anotheradmin@agency.MIL ).each do |email|
        user = User.create!(@valid_affiliate_attributes.merge(:email => email))
        expect(user.requires_manual_approval?).to be false
      end
    end

    it "should set requires_manual_approval if the user is an affiliate and the email is not government_affiliated" do
      %w( aff@agency.COM aff@anotheragency.com admin.gov@agency.org anotheradmin.MIL@agency.ORG escape_the_dot@foo.xmil ).each do |email|
        user = User.create!(@valid_affiliate_attributes.merge(:email => email))
        expect(user.requires_manual_approval?).to be true
      end
    end

    it "should set email_verification_token if the user is pending_email_verification" do
      user = User.create!(@valid_affiliate_attributes)
      expect(user.is_pending_email_verification?).to be true
      expect(user.email_verification_token).not_to be_blank
    end

    context "when the same email_verification_token as another user is generated" do
      let(:user) { User.new(valid_attributes).tap { |u| puts u.inspect } }
      let(:token) { 'unique token' }

      before do
        existing_user = users(:affiliate_manager_with_pending_contact_information_status)
        allow(Authlogic::Random).to receive(:friendly_token).and_return(
          'salt_for_user_password',                # for the initial User.new
          existing_user.email_verification_token,  # induces uniqueness error
          token                                    # final value works because it's unique
        )
      end

      it "doesn't raise the uniqueness constraint violation error" do
        expect { user.save(valid_attributes)}.to_not raise_error
      end

      it "assigns a new email_verification_token" do
        user.save
        expect(user.email_verification_token).to eq(token)
      end
    end
  end

  context "when saving/updating" do
    it { is_expected.to allow_value("pending_email_verification").for(:approval_status) }
    it { is_expected.to allow_value("pending_approval").for(:approval_status) }
    it { is_expected.to allow_value("approved").for(:approval_status) }
    it { is_expected.to allow_value("not_approved").for(:approval_status) }

    context 'when updating an email address' do
      let(:user) { users(:affiliate_admin) }
      let(:new_email) { 'new@new.gov' }
      subject(:update_email) { user.update(email: new_email) }
      before { allow(Emailer).to receive(:user_email_verification).with(an_instance_of(User)).and_return @emailer }

      it 'requires re-verification' do
        expect{ update_email }.to change{ user.reload.approval_status }
          .from('approved').to('pending_email_verification')
      end

      it 'resends the verification email' do
        expect(Emailer).to receive(:user_email_verification).with(user)
        update_email
      end

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

  describe "#verify_email" do
    context "has matching email verification token and does not require manual approval" do
      before do
        @user = users(:affiliate_added_by_another_affiliate_with_pending_email_verification_status)
        expect(@user.is_pending_email_verification?).to be true
        expect(@user.welcome_email_sent?).to be false
        expect(@user.verify_email(@user.email_verification_token)).to be true
      end

      it "should update the approval_status to approved" do
        expect(@user.is_approved?).to be true
      end

      it "should update welcome_email_sent flag to true" do
        expect(@user.welcome_email_sent?).to be true
      end
    end

    context "has matching email verification token and requires manual approval" do
      before do
        @user = User.create!(@valid_affiliate_attributes.merge(:email => 'not.gov@agency.com'))
        expect(@user.is_pending_email_verification?).to be true
        @user = User.find_by_email('not.gov@agency.com')
        expect(@user.welcome_email_sent?).to be false
        expect(@user.verify_email(@user.email_verification_token)).to be true
      end

      it "should update the approval_status to pending_approval" do
        expect(@user.is_pending_approval?).to be true
      end

      it "should not update the welcome_email_sent flag" do
        expect(@user.welcome_email_sent?).to be false
      end
    end

    context "when the user is already approved" do
      let(:user) { users(:affiliate_manager) }

      before { user.update(email_verification_token: 'token') }

      it "should return true" do
        expect(user.is_approved?).to be true
        expect(user.verify_email('token')).to be true
      end

      context 'and the token does not match' do
        it 'should return false' do
          expect(user.verify_email('wrong_token')).to be false
        end
      end

      context 'when the user has already received a welcome email' do
        before do
          user.update(approval_status: 'pending_email_verification',
                                  welcome_email_sent: true)
        end

        it 'does not re-send the welcome email' do
          expect(user).to_not receive(:send_welcome_to_new_user_email)
          user.verify_email('token')
        end
      end
    end

    it "should return false if the user does not have matching email_verification_token" do
      user = users(:affiliate_manager_with_pending_email_verification_status)
      expect(user.verify_email('mismatched token')).to be false
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

  describe "#new_invited_by_affiliate" do
    let(:inviter) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }

    context "when contact_name and email are provided" do

      it "should initialize new user with assign affiliate, contact_name, and email" do
        new_user = User.new_invited_by_affiliate(inviter, affiliate, { :contact_name => 'New User Name', :email => 'newuser@approvedagency.com' })
        new_user.save!
        expect(new_user.affiliates.first).to eq(affiliate)
        expect(new_user.contact_name).to eq('New User Name')
        expect(new_user.email).to eq('newuser@approvedagency.com')
        expect(new_user.is_affiliate?).to be true
        expect(new_user.requires_manual_approval).to be false
        expect(new_user.is_pending_email_verification?).to be true
        expect(new_user.welcome_email_sent).to be false
        expect(affiliate.users).to include(new_user)
      end

      it "should receive welcome new user added by affiliate email verification" do
        expect(Emailer).to receive(:welcome_to_new_user_added_by_affiliate).and_return @emailer
        expect(Emailer).to_not receive(:new_user_email_verification)
        new_user = User.new_invited_by_affiliate(inviter, affiliate, { :contact_name => 'New User Name', :email => 'newuser@approvedagency.com' })
        new_user.save!
        expect(new_user.email_verification_token).not_to be_blank
      end
    end
  end

  describe "#complete_registration" do
    let(:inviter) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }

    before do
      @user = User.new_invited_by_affiliate(inviter, affiliate, { :contact_name => 'New User Name', :email => 'newuser@approvedagency.com' })
      @user.save!
    end

    context "when executed" do
      let(:user) { user = User.find @user.id }

      before do
        expect(user).to receive(:update)
        expect(Emailer).to_not receive(:welcome_to_new_user)
        user.complete_registration({})
      end

      it { expect(user).to be_is_approved }
      it "should set email_verification_token to nil" do
        expect(user.email_verification_token).to be_nil
      end

      it "requires a password" do
        expect(user.require_password).to be true
      end
    end

    context 'when password is blank' do
      let(:user) { user = User.find @user.id }
      specify { expect(user.complete_registration({ password: '' })).to be false }
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

  describe '#password_updated_at' do
    let(:user) { users(:affiliate_admin) }

    it 'is set when the user is created' do
      expect(user.password_updated_at).to_not be_nil
    end

    it 'is set when the password is updated' do
      expect { user.update(password: "new1234!") }.
        to change{ user.password_updated_at }
    end

    it 'is not set when other attributes are updated' do
      expect { user.update(contact_name: 'Kermit the Frog') }.
        to_not change{ user.password_updated_at }
    end

    it 'is not set when the password is blank' do
      expect { user.update(email: 'new@example.com', password: '') }.
        to_not change{ user.password_updated_at }
    end
  end

  describe '#requires_password_reset?' do
    subject { user.requires_password_reset? }

    context 'when the password has never been reset' do
      let(:user) { User.new }

      it { is_expected.to eq true }
    end

    context 'when the password has been reset more than 90 days ago' do
      let(:user) { User.new(password_updated_at: 91.days.ago) }

      it { is_expected.to eq true }
    end

    context 'when the password has been reset within 90 days' do
      let(:user) { User.new(password_updated_at: 89.days.ago) }

      it { is_expected.to eq false }
    end
  end
end
