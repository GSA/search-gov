# frozen_string_literal: true

require 'spec_helper'

describe Scheduled::UpdateNotActiveApprovalStatusJob do
  fixtures :users

  subject(:perform) { described_class.perform_now }

  let(:not_active_user) { users(:not_active_user) }

  it 'sets not active users to timed_out' do
    perform
    expect(not_active_user.reload.timed_out?).to be true
  end

  it 'logs the start and how many users were timed out' do
    updated_user_count = User.approved.not_active.count

    allow(Rails.logger).to receive(:info)

    perform

    expect(Rails.logger).to have_received(:info).with('UpdateNotActiveApprovalStatusJob started')
    expect(Rails.logger).to have_received(:info).with(
      "UpdateNotActiveApprovalStatusJob completed: timed out #{updated_user_count} user(s)"
    )
  end
end
