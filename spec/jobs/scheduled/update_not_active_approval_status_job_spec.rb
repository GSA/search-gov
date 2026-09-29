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
end
