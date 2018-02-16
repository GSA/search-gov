require 'spec_helper'

describe Admin::HintsController do
  fixtures :users, :affiliates, :memberships

  describe '#reload_hints' do
    before do
      activate_authlogic
      UserSession.create(users('affiliate_admin'))
    end

    context 'when HintData.reload is successful' do
      before do
        expect(HintData).to receive(:reload).and_return({})
        get :reload_hints
      end

      it { is_expected.to set_flash.now.to('Reload complete.') }
    end

    context 'when HintData.reload returns with error' do
      before do
        expect(HintData).to receive(:reload).and_return(error: 'Unable to fetch url')
        get :reload_hints
      end

      it { is_expected.to set_flash.now.to('Unable to fetch url') }
    end
  end
end
