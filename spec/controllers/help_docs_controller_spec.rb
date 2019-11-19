require 'spec_helper'

describe HelpDocsController do
  fixtures :users

  describe '#show' do
    context 'when url matches search.gov' do
      let(:url) { 'https://search.gov/manual/site-information.html' }

      before { activate_authlogic }
      include_context 'approved user logged in'

      before do
        expect(HelpDoc).to receive(:extract_article).with(url).and_return 'Site Information'
        get :show, params: { url: url }, format: :json
      end

      it { respond_with :success }
      specify { expect(response.body).to include('Site Information') }
    end

    context 'when url does not match search.gov' do
      let(:url) { 'http://NOT.search.gov/manual/site-information.html' }

      before do
        expect(HelpDoc).not_to receive(:extract_article)
        get :show, params: { url: url }, format: :json
      end

      it { is_expected.to redirect_to('https://www.usa.gov/search-error') }
    end

    context 'when url does match search.gov with newline characters' do
      let(:url) do
        "https://search.gov/manual/site-information.html\n<script>dangerous_stuff();</script>"
      end

      before do
        expect(HelpDoc).not_to receive(:extract_article)
        get :show, params: { url: url }, format: :json
      end
      it { is_expected.to redirect_to('https://www.usa.gov/search-error') }
    end


    context 'when user is not logged in' do
      let(:url) { 'https://search.gov/manual/site-information.html' }

      before { get :show, params: { url: url }, format: :json }

      it { respond_with :bad_request }
    end
  end
end
