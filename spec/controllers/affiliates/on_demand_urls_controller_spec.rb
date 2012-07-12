require 'spec/spec_helper'

describe Affiliates::OnDemandUrlsController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "#new" do
    context "when affiliate manager is not logged in" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        get :new, :affiliate_id => affiliate.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:another_affiliate) { affiliates(:another_affiliate) }

      before do
        UserSession.create(users(:affiliate_manager))
        get :new, :affiliate_id => another_affiliate.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:indexed_document) { mock('indexed document') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:indexed_documents, :build).and_return(indexed_document)

        get :new, :affiliate_id => affiliate.id
      end

      it { should assign_to(:title).with_kind_of(String) }
      it { should assign_to(:indexed_document).with(indexed_document) }
      it { should respond_with(:success) }
    end
  end

  describe "#create" do
    context "when affiliate manager is not logged in" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        post :create, :affiliate_id => affiliate.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:another_affiliate) { affiliates(:another_affiliate) }

      before do
        UserSession.create(users(:affiliate_manager))
        post :create, :affiliate_id => another_affiliate.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully create a URL" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:indexed_document) { mock_model(IndexedDocument, :url => 'http://www.agency.gov/document1.html') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.stub_chain(:indexed_documents, :build).and_return(indexed_document)
        indexed_document.should_receive(:save).and_return(true)
      end

      context "Rails request/response stuff" do
        before do
          post :create, :affiliate_id => affiliate.id, :indexed_document => {:url => 'http://www.agency.gov/document1.html'}
        end

        it { should assign_to(:indexed_document).with(indexed_document) }
        it { should set_the_flash }
        it { should redirect_to(uncrawled_affiliate_on_demand_urls_path(affiliate)) }
      end

      it "should enqueue the high-priority indexing of the IndexedDocument via Resque" do
        ResqueSpec.reset!
        Resque.should_receive(:enqueue_with_priority).with(:high, IndexedDocumentFetcher, an_instance_of(Fixnum))
        post :create, :affiliate_id => affiliate.id, :indexed_document => {:url => 'http://www.agency.gov/another.html'}
      end
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and failed to create a URL" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:indexed_document) { mock_model(IndexedDocument, :url => 'http://www.agency.gov/document1.html') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.stub_chain(:indexed_documents, :build).and_return(indexed_document)
        indexed_document.should_receive(:save).and_return(false)

        post :create, :affiliate_id => affiliate.id, :indexed_document => {:url => 'http://www.agency.gov/document1.html'}
      end

      it { should assign_to(:indexed_document).with(indexed_document) }
      it { should assign_to(:title).with_kind_of(String) }
      it { should render_template(:new) }
    end
  end

  describe "#crawled" do
    context "when affiliate manager is not logged in" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        get :crawled, :affiliate_id => affiliate.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:another_affiliate) { affiliates(:another_affiliate) }

      before do
        UserSession.create(users(:affiliate_manager))
        get :crawled, :affiliate_id => another_affiliate.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:crawled_urls) { mock('crawled urls') }

      before do
        UserSession.create(current_user)
        IndexedDocument.should_receive(:crawled_urls).and_return(crawled_urls)

        get :crawled, :affiliate_id => affiliate.id
      end

      it { should assign_to(:title).with_kind_of(String) }
      it { should assign_to(:crawled_urls).with(crawled_urls) }
      it { should respond_with(:success) }
    end
  end

  describe "#destroy" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:indexed_document) { mock_model(IndexedDocument, :url => 'http://www.agency.gov/document1.html') }
    let(:another_indexed_document) { mock_model(IndexedDocument) }

    context "when affiliate manager is not logged in" do
      before do
        delete :destroy, :affiliate_id => affiliate.id, :id => indexed_document.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        delete :destroy, :affiliate_id => another_affiliate.id, :id => indexed_document.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the indexed document" do
      before do
        UserSession.create(current_user)
        delete :destroy, :affiliate_id => affiliate.id, :id => another_indexed_document.id
      end

      it { should redirect_to(urls_and_sitemaps_affiliate_path(affiliate)) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully delete the indexed document" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:indexed_documents, :find_by_id).with(indexed_document.id.to_s).and_return(indexed_document)
        indexed_document.should_receive(:destroy)

        request.env["HTTP_REFERER"] = urls_and_sitemaps_affiliate_url(affiliate)
        delete :destroy, :affiliate_id => affiliate.id, :id => indexed_document.id
      end

      it { should set_the_flash }
      it { should redirect_to(:back) }
    end
  end

  describe "#upload" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:url_file) { mock("url_file") }

    context "when logged in as an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_manager))
      end

      context "when the affiliate owns the affiliate and successfully bulk upload URLs" do
        before do
          IndexedDocument.should_receive(:process_file).with(url_file.to_s, affiliate, IndexedDocument::MAX_URLS_PER_FILE_UPLOAD).and_return({:success => true, :count => 5})
          post :upload, :affiliate_id => affiliate.id, :indexed_documents => url_file
        end

        it { should redirect_to(uncrawled_affiliate_on_demand_urls_path(affiliate)) }
        it { should set_the_flash.to(/Successfully uploaded 5 urls./) }
      end

      context "when the affiliate owns the affiliate and failed to bulk upload boosted contents" do
        before do
          IndexedDocument.should_receive(:process_file).with(url_file.to_s, affiliate, IndexedDocument::MAX_URLS_PER_FILE_UPLOAD).and_return({:success => false, :error_message => 'error'})
          post :upload, :affiliate_id => affiliate.id, :indexed_documents => url_file
        end

        it { should assign_to(:title) }
        it { should set_the_flash.now.to(/error/) }
        it { should render_template(:bulk_new) }
      end
    end

    context "when logged in as an admin" do
      before do
        UserSession.create(users(:affiliate_admin))
      end

      it "should not limit the number of urls" do
        IndexedDocument.should_receive(:process_file).with(url_file.to_s, affiliate, 0).and_return({:success => true, :count => 5})
        post :upload, :affiliate_id => affiliate.id, :indexed_documents => url_file
      end
    end
  end

  describe "#export_crawled" do
    context "when affiliate manager is not logged in" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        get :export_crawled, :affiliate_id => affiliate.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:another_affiliate) { affiliates(:another_affiliate) }

      before do
        UserSession.create(users(:affiliate_manager))
        get :export_crawled, :affiliate_id => another_affiliate.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:crawled_urls) { mock('crawled URLs') }
      let(:indexed_documents) { mock('indexed documents')}
      let(:selected_fields) { mock('selected fields') }
      let(:doc) { mock_model(IndexedDocument,
                             :url => 'http://url.to/my/doc.html',
                             :title => 'my title',
                             :description => 'my description',
                             :doctype => 'html',
                             :last_crawled_at => '2011-12-05 14:15:44 UTC',
                             :last_crawl_status => 'OK') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:indexed_documents).and_return(indexed_documents)
        indexed_documents.should_receive(:fetched).and_return(crawled_urls)
        crawled_urls.should_receive(:select).and_return(selected_fields)
        selected_fields.should_receive(:paginate).and_return([doc])

        get :export_crawled, :affiliate_id => affiliate.id, :format => 'csv'
      end

      it { should respond_with_content_type(:csv) }
      it { should respond_with(:success) }

      it "should render csv header" do
        response.body.should include("url,title,description,doctype,last_crawled_at,last_crawl_status")
      end

      it "should render csv data" do
        response.body.should include("http://url.to/my/doc.html,my title,my description,html,2011-12-05 14:15:44 UTC,OK")
      end
    end
  end
end