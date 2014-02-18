require 'spec_helper'

describe HelpDocsController do
  describe '#show' do
    let(:url) { 'http://search.digitalgov.gov/manual/site-information.html' }

    before do
      HelpDoc.should_receive(:extract_article).with(url).and_return 'Site Information'
      get :show, url: url, format: :json
    end

    it { should be_ssl_required }
    it { respond_with :success }
    specify { response.body.should include('Site Information') }
  end
end
