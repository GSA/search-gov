require 'spec_helper'

describe Sites::IndexedDocumentsController do
  fixtures :users, :affiliates, :memberships
  before { activate_authlogic }

  describe '#index' do
    it_should_behave_like 'restricted to approved user', :get, :index

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      let(:indexed_documents) { mock('indexed documents') }

      before do
        site.stub_chain(:indexed_documents, :by_matching_url, :paginate).and_return(indexed_documents)
        get :index, site_id: site.id
      end

      it { should assign_to(:site).with(site) }
      it { should assign_to(:indexed_documents).with(indexed_documents) }
    end
  end

  describe '#create' do
    it_should_behave_like 'restricted to approved user', :post, :create

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      context 'when Indexed Document params are valid' do
        let(:indexed_document) { mock_model(IndexedDocument, url: 'http://usasearch.howto.gov/developer/jobs.html') }

        before do
          indexed_documents = mock('indexed documents')
          site.stub(:indexed_documents).and_return(indexed_documents)
          indexed_documents.should_receive(:build).
              with('url' => 'http://usasearch.howto.gov/developer/jobs.html',
                   'title' => 'Jobs API',
                   'description' => 'Helping job seekers land a job with the government.',
                   'source' => 'manual',
                   'last_crawl_status' => 'summarized').
              and_return(indexed_document)

          indexed_document.should_receive(:save).and_return(true)
          Resque.should_receive(:enqueue_with_priority).
              with(:high, IndexedDocumentFetcher, indexed_document.id)

          post :create,
               site_id: site.id,
               indexed_document: { url: 'http://usasearch.howto.gov/developer/jobs.html',
                                   title: 'Jobs API',
                                   description: 'Helping job seekers land a job with the government.',
                                   not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:indexed_document).with(indexed_document) }
        it { should redirect_to site_supplemental_urls_path(site) }
        it { should set_the_flash.to('You have added usasearch.howto.gov/developer/jobs.html to this site.') }
      end

      context 'when Indexed Document params are not valid' do
        let(:indexed_document) { mock_model(IndexedDocument, url: 'usagov') }

        before do
          indexed_documents = mock('indexed documents')
          site.stub(:indexed_documents).and_return(indexed_documents)
          indexed_documents.should_receive(:build).
              with('url' => 'http://usasearch.howto.gov/developer/jobs.html',
                   'title' => '',
                   'description' => '',
                   'source' => 'manual',
                   'last_crawl_status' => 'summarized').
              and_return(indexed_document)

          indexed_document.should_receive(:save).and_return(false)

          post :create,
               site_id: site.id,
               indexed_document: { url: 'http://usasearch.howto.gov/developer/jobs.html',
                                   title: '',
                                   description: '',
                                   not_allowed_key: 'not allowed value' }
        end

        it { should assign_to(:indexed_document).with(indexed_document) }
        it { should render_template(:new) }
      end
    end
  end

  describe '#destroy' do
    it_should_behave_like 'restricted to approved user', :delete, :destroy

    context 'when logged in as affiliate' do
      include_context 'approved user logged in to a site'

      before do
        indexed_documents = mock('indexed documents')
        site.stub(:indexed_documents).and_return(indexed_documents)

        indexed_document = mock_model(IndexedDocument,
                                      url: 'http://usasearch.howto.gov/developer/jobs.html',
                                      source_manual?: true)
        indexed_documents.should_receive(:find_by_id).with('100').
            and_return(indexed_document)
        indexed_document.should_receive(:destroy)

        delete :destroy, site_id: site.id, id: 100
      end

      it { should redirect_to(site_supplemental_urls_path(site)) }
      it { should set_the_flash.to('You have removed usasearch.howto.gov/developer/jobs.html from this site.') }
    end
  end
end
