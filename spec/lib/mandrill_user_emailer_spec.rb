require 'spec_helper'

describe MandrillUserEmailer do
  subject(:emailer) { described_class.new(user) }
  let(:user) do
    mock_model(User,
               email: 'upton@example.com',
               contact_name: 'Upton User',
               email_verification_token: 'verification_token',
               perishable_token: 'perishable_token')
  end

  before { allow(MandrillAdapter).to receive(:new).and_return(mandrill_adapter) }
  let(:mandrill_adapter) do
    double(:mandrill_adapter,
           send_user_email: nil,
           base_url_params: { protocol: 'https', host: 'search.hostname' },
           bcc_setting: 'bcc@example.com')
  end

  describe '.new' do
    its(:user) { should == user }
  end

  describe '#send_new_affiliate_user' do
    let(:affiliate) do
      mock_model(Affiliate,
                 id: 42,
                 name: 'abc',
                 display_name: 'ABC Affiliate',
                 website: 'http://affiliate.example.com')
    end
    let(:inviter_user) { mock_model(User, contact_name: 'Irene Inviter') }

    it 'sends new_affiliate_user email with appropriate merge fields' do
      expect(mandrill_adapter).to receive(:send_user_email).with(user, 'new_affiliate_user', {
        adder_contact_name: 'Irene Inviter',
        site_name: 'ABC Affiliate',
        site_handle: 'abc',
        site_homepage_url: 'http://affiliate.example.com',
        edit_site_url: 'https://search.hostname/sites/42',
      })
      emailer.send_new_affiliate_user(affiliate, inviter_user)
    end
  end

  describe '#send_email_verification' do
    it 'sends email_verification email with appropriate merge fields' do
      expect(mandrill_adapter).to receive(:send_user_email).with(user, 'email_verification', {
        email_verification_url: 'https://search.hostname/email_verification/verification_token',
      })
      emailer.send_email_verification
    end
  end

  describe '#send_password_reset_instructions' do
    it 'sends password_reset_instructions email with appropriate merge fields' do
      expect(mandrill_adapter).to receive(:send_user_email).with(user, 'password_reset_instructions', {
        password_reset_url: 'https://search.hostname/password_resets/perishable_token/edit',
      })
      emailer.send_password_reset_instructions
    end
  end

  describe '#send_welcome_to_new_user' do
    it 'sends welcome_to_new_user email with appropriate merge fields' do
      expect(mandrill_adapter).to receive(:send_user_email).with(user, 'welcome_to_new_user', {
        new_site_url: 'https://search.hostname/sites/new',
      })
      emailer.send_welcome_to_new_user
    end
  end

  describe '#send_welcome_to_new_user_added_by_affiliate' do
    let(:affiliate) do
      mock_model(Affiliate,
                 id: 43,
                 display_name: 'Another Affiliate',
                 website: 'http://another.example.com')
    end

    before do
      allow(user).to receive(:inviter).and_return(mock_model(User, contact_name: 'Ingrid Inviter'))
      allow(user).to receive(:affiliates).and_return([affiliate])
    end

    it 'sends welcome_to_new_user_added_by_affiliate email with appropriate merge fields' do
      expect(mandrill_adapter).to receive(:send_user_email).with(user, 'welcome_to_new_user_added_by_affiliate', {
        adder_contact_name: 'Ingrid Inviter',
        site_name: 'Another Affiliate',
        edit_site_url: 'https://search.hostname/sites/43',
        account_url: 'https://search.hostname/account',
        site_homepage_url: 'http://another.example.com',
        complete_registration_url: 'https://search.hostname/complete_registration/verification_token/edit',
      })
      emailer.send_welcome_to_new_user_added_by_affiliate
    end
  end
end
