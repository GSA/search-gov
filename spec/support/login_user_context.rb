# frozen_string_literal: true

shared_context 'login user' do
  let(:explicit_destination) { nil }

  before do
    stub_const('ACCESS_DENIED_TEXT', 'Access Denied')
    login(user) if user
  end

  let(:first_affiliate) do
    Affiliate.create(website: 'https://first-affiliate.gov',
                     display_name: 'First Affiliate',
                     name: 'first')
  end

  let(:second_affiliate) do
    Affiliate.create(website: 'https://second-affiliate.gov',
                     display_name: 'Second Affiliate',
                     name: 'second')
  end

  let(:user_approval_status) { 'approved' }
  let(:user_first_name) { 'firstname' }
  let(:user_last_name) { 'lastname' }
  let(:user_organization_name) { 'organization' }
  let(:user_affiliates) { [] }
  let(:user_default_affiliate) { nil }
  let(:user_is_super_admin) { false }

  let(:user) do
    user = User.create(
      email: 'fake.user@agency.gov',
      first_name: user_first_name,
      last_name: user_last_name,
      organization_name: user_organization_name,
      approval_status: user_approval_status,
      is_affiliate_admin: user_is_super_admin
    )

    user.inviter = user
    user.approval_status = user_approval_status
    user.affiliates = user_affiliates
    user.default_affiliate = user_default_affiliate
    user.save!

    user
  end
end
