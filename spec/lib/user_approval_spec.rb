# frozen_string_literal: true

describe 'user approval' do
  describe '.warn_set_to_not_approved' do
    subject(:warn_set_to_not_approved) do
      UserApproval.warn_set_to_not_approved([user], date)
    end
    let(:user) { users(:not_active_76_days) }
    let(:date) { 76.days.ago.to_date }


    it 'calls Emailer.account_deactivation_warning' do
      expect(Emailer).to receive(:account_deactivation_warning).
        with(user, date).and_call_original
      warn_set_to_not_approved
    end
  end
end