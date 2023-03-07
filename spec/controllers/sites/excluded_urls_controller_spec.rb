require 'spec_helper'

describe Sites::ExcludedUrlsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_behaves_like 'restricted to approved user', :get, :index, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:excluded_urls) { double('excluded urls') }

      before do
        allow(site).to receive_message_chain(:excluded_urls, :paginate, :order).and_return(excluded_urls)
        get :index, params: { site_id: site.id }
      end

      it { is_expected.to assign_to(:site).with(site) }
      it { is_expected.to assign_to(:excluded_urls).with(excluded_urls) }
    end
  end

  describe '#create' do
    it_behaves_like 'restricted to approved user', :post, :create, site_id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when Excluded URL params are valid' do
        let(:excluded_url) { mock_model(ExcludedUrl, url: 'http://agency.gov/exclude-me.html') }

        before do
          excluded_urls = double('excluded urls')
          allow(site).to receive(:excluded_urls).and_return(excluded_urls)
          expect(excluded_urls).to receive(:build).
            with({ 'url' => 'http://agency.gov/exclude-me.html' }).
            and_return(excluded_url)

          expect(excluded_url).to receive(:save).and_return(true)

          post :create,
               params: {
                 site_id: site.id,
                 excluded_url: { url: 'http://agency.gov/exclude-me.html',
                                 not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:excluded_url).with(excluded_url) }
        it { is_expected.to redirect_to site_filter_urls_path(site) }
        it { is_expected.to set_flash.to('You have added agency.gov/exclude-me.html to this site.') }
      end

      context 'when Excluded URL params are not valid' do
        let(:excluded_url) { mock_model(ExcludedUrl) }

        before do
          excluded_urls = double('excluded urls')
          allow(site).to receive(:excluded_urls).and_return(excluded_urls)
          expect(excluded_urls).to receive(:build).
            with({ 'url' => '' }).and_return(excluded_url)

          expect(excluded_url).to receive(:save).and_return(false)

          post :create,
               params: {
                 site_id: site.id,
                 excluded_url: { url: '',
                                 not_allowed_key: 'not allowed value' }
               }
        end

        it { is_expected.to assign_to(:excluded_url).with(excluded_url) }
        it { is_expected.to render_template(:new) }
      end
    end
  end

  describe '#destroy' do
    it_behaves_like 'restricted to approved user', :delete, :destroy, site_id: 100, id: 100

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        excluded_urls = double('excluded urls')
        allow(site).to receive(:excluded_urls).and_return(excluded_urls)

        excluded_url = mock_model(ExcludedUrl, url: 'agency.gov/exclude-me.html')
        expect(excluded_urls).to receive(:find_by_id).with('100').
          and_return(excluded_url)
        expect(excluded_url).to receive(:destroy)

        delete :destroy, params: { site_id: site.id, id: 100 }
      end

      it { is_expected.to redirect_to(site_filter_urls_path(site)) }
      it { is_expected.to set_flash.to('You have removed agency.gov/exclude-me.html from this site.') }
    end
  end
end
