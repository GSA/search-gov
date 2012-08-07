require 'spec_helper'

describe Affiliates::SitemapsController do
  fixtures :affiliates, :users
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
      let(:sitemaps) { mock('Sitemaps') }
      let(:sitemaps_with_paginate) { mock('Sitemaps with paginate') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:sitemaps).and_return(sitemaps)
        sitemaps.should_receive(:paginate).with(:per_page => 10,
                                                :page => nil).and_return(sitemaps_with_paginate)

        get :index, :affiliate_id => affiliate.id
      end

      it { should assign_to(:title).with_kind_of(String) }
      it { should assign_to(:sitemaps).with(sitemaps_with_paginate) }
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
      let(:sitemap) { mock('a Sitemap') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:sitemaps, :build).and_return(sitemap)

        get :new, :affiliate_id => affiliate.id
      end

      it { should assign_to(:title).with_kind_of(String) }
      it { should assign_to(:sitemap).with(sitemap) }
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

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully create a sitemap" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:sitemap) { mock_model(Sitemap) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.stub_chain(:sitemaps, :build).and_return(sitemap)
        sitemap.should_receive(:save).and_return(true)

        post :create, :affiliate_id => affiliate.id, :sitemap => { :url => 'http://www.dol.gov/TMP/public.xml' }
      end

      it { should assign_to(:sitemap).with(sitemap) }
      it { should set_the_flash }
      it { should redirect_to(affiliate_sitemaps_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and failed to create a sitemap" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:sitemap) { mock_model(Sitemap) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.stub_chain(:sitemaps, :build).and_return(sitemap)
        sitemap.should_receive(:save).and_return(false)

        post :create, :affiliate_id => affiliate.id, :sitemap => { :url => 'http://www.dol.gov/TMP/public.xml' }
      end

      it { should assign_to(:sitemap).with(sitemap) }
      it { should assign_to(:title).with_kind_of(String) }
      it { should render_template(:new) }
    end
  end
end
