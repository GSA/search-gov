require 'spec/spec_helper'

describe Affiliates::RssFeedsController do
  fixtures :affiliates, :users, :rss_feeds, :rss_feed_urls, :navigations
  before do
    activate_authlogic
  end

  describe "#index" do
    context "when affiliate manager is not logged in" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        get :index, :affiliate_id => affiliate.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:another_affiliate) { affiliates(:another_affiliate) }

      before do
        UserSession.create(users(:affiliate_manager))
        get :index, :affiliate_id => another_affiliate.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:rss_feeds) { mock('RSS Feeds') }
      let(:rss_feeds_with_paginate) { mock('RSS Feeds with paginate') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:rss_feeds).and_return(rss_feeds)
        rss_feeds.should_receive(:paginate).with(:per_page => 10, :page => nil).and_return(rss_feeds_with_paginate)

        get :index, :affiliate_id => affiliate.id
      end

      it { should assign_to(:title).with_kind_of(String) }
      it { should assign_to(:rss_feeds).with(rss_feeds_with_paginate) }
      it { should respond_with(:success) }
    end
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
      let(:rss_feed) { mock('rss_feed') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:rss_feeds, :build).and_return(rss_feed)

        get :new, :affiliate_id => affiliate.id
      end

      it { should assign_to(:title).with_kind_of(String) }
      it { should assign_to(:rss_feed).with(rss_feed) }
      it { should respond_with(:success) }
    end
  end

  describe "#create" do
    context "when affiliate manager is not logged in" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        post :create, :affiliate_id => affiliate.id, :rss_feed => {}
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:another_affiliate) { affiliates(:another_affiliate) }

      before do
        UserSession.create(users(:affiliate_manager))
        post :create, :affiliate_id => another_affiliate.id, :rss_feed => {}
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully create a RSS feed" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:rss_feed) { rss_feeds(:basic) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.stub_chain(:rss_feeds, :build).and_return(rss_feed)
        rss_feed.should_receive(:save).and_return(true)

        post :create, :affiliate_id => affiliate.id, :rss_feed => { :url => 'http://something.gov/feed', :name => 'gov feed name' }
      end

      it { should assign_to(:rss_feed).with(rss_feed) }
      it { should set_the_flash }
      it { should redirect_to([affiliate, rss_feed]) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and failed to create a RSS feed" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:rss_feed) { rss_feeds(:basic) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.stub_chain(:rss_feeds, :build).and_return(rss_feed)
        rss_feed.should_receive(:save).and_return(false)

        post :create, :affiliate_id => affiliate.id, :rss_feed => { :url => 'http://something.gov/feed', :name => 'gov feed name' }
      end

      it { should assign_to(:rss_feed).with(rss_feed) }
      it { should render_template(:new) }
    end
  end

  describe "#show" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:rss_feed) { rss_feeds(:basic) }
    let(:another_rss_feed) { rss_feeds(:another) }

    context "when affiliate manager is not logged in" do
      before do
        get :show, :affiliate_id => affiliate.id, :id => rss_feed.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :show, :affiliate_id => another_affiliate.id, :id => rss_feed.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested" do
      before do
        UserSession.create(current_user)
        get :show, :affiliate_id => affiliate.id, :id => rss_feed.id
      end

      it { should assign_to(:rss_feed).with(rss_feed) }
      it { should assign_to(:title).with_kind_of(String) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the RSS feed" do
      before do
        UserSession.create(current_user)
        get :show, :affiliate_id => affiliate.id, :id => another_rss_feed.id
      end

      it { should redirect_to(affiliate) }
    end

  end

  describe "#edit" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:rss_feed) { rss_feeds(:basic) }
    let(:another_rss_feed) { rss_feeds(:another) }

    context "when affiliate manager is not logged in" do
      before do
        get :edit, :affiliate_id => affiliate.id, :id => rss_feed.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :edit, :affiliate_id => another_affiliate.id, :id => rss_feed.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the RSS feed" do
      before do
        UserSession.create(current_user)
        get :edit, :affiliate_id => affiliate.id, :id => another_rss_feed.id
      end

      it { should redirect_to(affiliate_path(affiliate)) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:rss_feeds, :find_by_id).with(rss_feed.id.to_s).and_return(rss_feed)

        get :edit, :affiliate_id => affiliate.id, :id => rss_feed.id
      end

      it { should assign_to(:title).with_kind_of(String) }
      it { should assign_to(:rss_feed).with(rss_feed) }
    end
  end

  describe "#update" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:rss_feed) { rss_feeds(:basic) }
    let(:another_rss_feed) { rss_feeds(:another) }

    context "when affiliate manager is not logged in" do
      before do
        post :update, :affiliate_id => affiliate.id, :id => rss_feed.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        post :update, :affiliate_id => another_affiliate.id, :id => rss_feed.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the RSS feed" do
      before do
        UserSession.create(current_user)
        post :update, :affiliate_id => affiliate.id, :id => another_rss_feed.id
      end

      it { should redirect_to(affiliate) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully update a RSS feed" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:rss_feeds, :find_by_id).with(rss_feed.id.to_s).and_return(rss_feed)
        rss_feed.should_receive(:update_attributes).and_return(true)

        post :update, :affiliate_id => affiliate.id, :id => rss_feed.id, :rss_feed => { "url" => "http://somethinglese.gov/feed" }
      end

      it { should assign_to(:rss_feed).with(rss_feed) }
      it { should set_the_flash }
      it { should redirect_to([affiliate, rss_feed]) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and failed to update a RSS feed" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:rss_feeds, :find_by_id).with(rss_feed.id.to_s).and_return(rss_feed)
        rss_feed.should_receive(:update_attributes).and_return(false)

        post :update, :affiliate_id => affiliate.id, :id => rss_feed.id, :rss_feed => { "url" => "" }
      end

      it { should assign_to(:rss_feed).with(rss_feed) }
      it { should render_template(:edit) }
    end
  end

  describe "#destroy" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:rss_feed) { rss_feeds(:basic) }
    let(:another_rss_feed) { rss_feeds(:another) }

    context "when affiliate manager is not logged in" do
      before do
        delete :destroy, :affiliate_id => affiliate.id, :id => rss_feed.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        delete :destroy, :affiliate_id => another_affiliate.id, :id => rss_feed.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the RSS feed" do
      before do
        UserSession.create(current_user)
        delete :destroy, :affiliate_id => affiliate.id, :id => another_rss_feed.id
      end

      it { should redirect_to(affiliate) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully delete a RSS feed" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:rss_feeds, :find_by_id).with(rss_feed.id.to_s).and_return(rss_feed)
        rss_feed.should_receive(:destroy)

        delete :destroy, :affiliate_id => affiliate.id, :id => rss_feed.id
      end

      it { should redirect_to(affiliate_rss_feeds_path(affiliate)) }
      it { should set_the_flash }
    end
  end
end
