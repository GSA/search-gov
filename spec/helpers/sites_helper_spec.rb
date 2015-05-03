require 'spec_helper'

describe SitesHelper do
  describe "#daily_snapshot_toggle(membership)" do
    context 'when membership is nil' do
      it 'should return nil' do
        helper.daily_snapshot_toggle(nil).should be_nil
      end
    end
  end

  describe '#user_row_css_class_hash' do
    let(:approval_status) { example.metadata[:approval_status] }
    let(:user) { mock_model(User, approval_status: approval_status) }
    let(:subject) { helper.user_row_css_class_hash(user) }

    context 'when User has', approval_status: 'pending_email_verification' do
      specify { expect(subject).to eq(class: 'warning') }
    end

    context 'when User has', approval_status: 'pending_approval' do
      specify { expect(subject).to eq(class: 'warning') }
    end

    context 'when User has', approval_status: 'not_approved' do
      specify { expect(subject).to eq(class: 'error') }
    end
  end
end
