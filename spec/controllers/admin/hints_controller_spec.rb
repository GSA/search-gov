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
        HintData.should_receive(:reload).and_return({})
        get :reload_hints
      end

      it { should set_the_flash.to('Reload complete.').now }
    end

    context 'when HintData.reload returns with error' do
      before do
        HintData.should_receive(:reload).and_return(error: 'Unable to fetch url')
        get :reload_hints
      end

      it { should set_the_flash.to('Unable to fetch url').now }
    end
  end
end
