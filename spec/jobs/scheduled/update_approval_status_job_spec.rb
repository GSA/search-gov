# frozen_string_literal: true

require 'spec_helper'

describe Scheduled::UpdateApprovalStatusJob do
  fixtures :users, :affiliates, :memberships

  subject(:perform) { described_class.perform_now }

  let(:user) { users(:affiliate_manager_with_no_affiliates) }
  let(:user_with_one_site) { users(:affiliate_manager_with_one_site) }
  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    user_with_one_site.affiliates << affiliate
    user_with_one_site.save!
  end

  it 'sets site-less users to not_approved' do
    perform
    expect(user.reload.is_not_approved?).to be true
  end

  it 'leaves approved users with sites as approved' do
    perform
    expect(user_with_one_site.reload.is_approved?).to be true
  end
end
