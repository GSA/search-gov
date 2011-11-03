require 'spec/spec_helper'

describe Affiliates::OnDemandUrlsController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "#index" do
    context "when viewing IndexedDocument urls for an affiliate" do
      before do
        @affiliate = affiliates("basic_affiliate")
      end

      context "when not logged in" do
        it "should redirect to the home page" do
          get :index, :affiliate_id => @affiliate.id
          response.should redirect_to login_path
        end
      end

      context "when logged in as an admin" do
        before do
          @user = users("affiliate_admin")
          @user.affiliates << @affiliate
          UserSession.create(@user)
        end

        it "should allow the admin to view IndexedDocument urls for his own affiliate" do
          get :index, :affiliate_id => @user.affiliates.first.id
          response.should be_success
        end

        it "should allow the admin to view IndexedDocument urls for other user's affiliates" do
          @affiliate = affiliates("basic_affiliate")
          get :index, :affiliate_id => @affiliate.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end
      end

      context "when logged in as an affiliate" do
        before do
          @user = users("affiliate_manager")
          UserSession.create(@user)
        end

        it "should allow the affiliate to view his own IndexedDocument urls" do
          get :index, :affiliate_id => @user.affiliates.first.id
          response.should_not redirect_to(home_page_path)
          response.should be_success
        end

        it "should not allow the affiliate to view IndexedDocument urls for other affiliates" do
          other_user = users("another_affiliate_manager")
          get :index, :affiliate_id => other_user.affiliates.first.id
          response.should redirect_to(home_page_path)
        end

        context "when viewing the page" do
          before do
            IndexedDocument.create(:url => 'http://uncrawled.gov', :affiliate => @user.affiliates.first)
            IndexedDocument.create(:url => 'http://crawled.gov', :title => "Title", :body => "Body", :description => "Description", :last_crawled_at => Time.now, :last_crawl_status => IndexedDocument::OK_STATUS, :affiliate => @user.affiliates.first)
          end

          it "should create a new IndexedDocument, and find all the uncrawled and the first 30 crawled IndexedDocuments urls" do
            get :index, :affiliate_id => @user.affiliates.first.id
            assigns[:indexed_document].should_not be_nil
            assigns[:uncrawled_urls].size.should == 1
            assigns[:crawled_urls].size.should == 1
          end
        end
      end
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
end