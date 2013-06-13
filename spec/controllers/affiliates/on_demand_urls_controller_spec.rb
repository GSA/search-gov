require 'spec_helper'

describe Affiliates::OnDemandUrlsController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
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
      let(:indexed_documents) { mock('indexed documents') }
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