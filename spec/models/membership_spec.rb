require 'spec_helper'

describe Membership do
  fixtures :affiliates, :users, :memberships

  describe 'scopes' do
    describe '.daily_snapshot_receivers' do
      subject(:receivers) { described_class.daily_snapshot_receivers }
      let!(:membership) { memberships(:four) }
      let!(:affiliate) { membership.affiliate }
      let!(:user) { membership.user }


      it { is_expected.to include(membership) }

      context 'when the user is not approved' do
        before { user.update_column(:approval_status, 'pending_approval') }

        it { is_expected.not_to include(membership) }
      end

      context 'when the user does not receive the daily snapshot email' do
        before { membership.update_column(:gets_daily_snapshot_email, false) }

        it { is_expected.not_to include(membership) }
      end

      context 'when the affiliate is inactive' do
        before { affiliate.update_column(:active, false) }

        it { is_expected.not_to include(membership) }
      end
    end
  end

  describe '#dup' do
    subject(:original_instance) { memberships(:four) }
    include_examples 'site dupable'
  end
end
