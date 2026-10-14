# frozen_string_literal: true

require 'spec_helper'

describe Scheduled::WarnSetToNotApprovedJob do
  fixtures :users

  subject(:perform) { described_class.perform_now(76) }

  let(:users) { User.approved.not_active_since(76.days.ago.to_date) }
  let(:not_approved_users) { User.not_approved.not_active_since(76.days.ago.to_date) }

  it 'warns approved users inactive for the given number of days' do
    expect(UserApproval).to receive(:warn_set_to_not_approved).
      with(users, 76.days.ago.to_date)
    perform
  end

  it 'will not call warn_set_to_not_approved on not approved users' do
    expect(UserApproval).not_to receive(:warn_set_to_not_approved).
      with(not_approved_users, 76.days.ago.to_date)
    perform
  end

  it 'will not call warn_set_to_not_approved prematurely' do
    expect(UserApproval).not_to receive(:warn_set_to_not_approved).
      with(users, 75.days.ago.to_date)
    perform
  end
end
