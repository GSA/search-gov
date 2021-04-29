# frozen_string_literal: true

describe SitesHelper do
  describe '#site_select' do
    let(:active_affiliate) { mock_model(Affiliate, display_name: 'Active', name: 'active') }
    let(:inactive_affiliate) { mock_model(Affiliate, display_name: 'Inactive', name: 'Inactive') }

    context 'when the user is a super admin' do
      let(:user) { mock_model(User, is_affiliate_admin: true) }

      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(user).to receive(:affiliates).
          and_return([active_affiliate, inactive_affiliate])
      end

      it 'returns a drop-down for all affiliates' do
        expect(helper.site_select).to match(/Active.+\n.+Inactive/)
      end
    end

    context 'when the user is not a super admin' do
      let(:user) { mock_model(User, is_affiliate_admin: false) }

      before do
        allow(helper).to receive(:current_user).and_return(user)
        allow(user).to receive_message_chain(:affiliates, :active).and_return([active_affiliate])
      end

      it 'returns a drop-down for active affiliates' do
        expect(helper.site_select).to match(/Active/)
        expect(helper.site_select).not_to match(/Inactive/)
      end
    end
  end

  describe '#daily_snapshot_toggle(membership)' do
    context 'when membership is nil' do
      it 'returns nil' do
        expect(helper.daily_snapshot_toggle(nil)).to be_nil
      end
    end
  end

  describe '#user_row_css_class_hash' do
    let(:approval_status) { RSpec.current_example.metadata[:approval_status] }
    let(:user) { mock_model(User, approval_status: approval_status) }
    let(:subject) { helper.user_row_css_class_hash(user) }

    context 'when User has', approval_status: 'pending_approval' do
      specify { expect(subject).to eq(class: 'warning') }
    end

    context 'when User has', approval_status: 'not_approved' do
      specify { expect(subject).to eq(class: 'error') }
    end
  end

  describe '#generate_jwt' do
    let(:affiliate) { mock_model(Affiliate, id: 491, name: 'somename', display_name: 'Somename Displayed', api_access_key: 'somekey') }
    let(:subject) { helper.generate_jwt(affiliate) }
    it 'should be decryptable using the JWT secret' do
      expect(subject).to be_kind_of(String)
      decoded = JWT.decode subject, SC_ACCESS_KEY, 'HS256'
      expect(decoded).to be_kind_of(Array)
      payload = decoded[0]
      expect(payload['affiliateName']).to eq('somename')
      expect(payload['expiration']).to be
    end
  end
end
