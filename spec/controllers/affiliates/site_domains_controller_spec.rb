require 'spec/spec_helper'

describe Affiliates::SiteDomainsController do
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
      let(:site_domains) { mock('Site Domains') }
      let(:site_domains_with_paginate) { mock('Site Domains with paginate') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:site_domains).and_return(site_domains)
        site_domains.should_receive(:paginate).with(:per_page => SiteDomain.per_page, :page => nil, :order => 'updated_at DESC, id DESC').and_return(site_domains_with_paginate)

        get :index, :affiliate_id => affiliate.id
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:site_domains).with(site_domains_with_paginate) }
      it { should respond_with(:success) }
    end
  end

  describe "#new" do
    context "when logged in as an affiliate manager who belongs to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:site_domains) { mock('Site Domains') }
      let(:site_domain) { mock('Site Domain') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:site_domains).and_return(site_domains)
        site_domains.should_receive(:build).and_return(site_domain)

        get :new, :affiliate_id => affiliate.id
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:site_domain).with(site_domain) }
      it { should respond_with(:success) }
    end
  end

  describe "#create" do
    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully create a site domain" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:site_domain) { mock_model(SiteDomain) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.stub_chain(:site_domains, :build).and_return(site_domain)
        site_domain.should_receive(:save).and_return(true)
        affiliate.should_receive(:normalize_site_domains)
        post :create, :affiliate_id => affiliate.id, :site_domain => { :domain => 'usa.gov' }
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:site_domain).with(site_domain) }
      it { should set_the_flash }
      it { should redirect_to(affiliate_site_domains_path(affiliate)) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and failed to create a site domain" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:site_domain) { mock_model(SiteDomain) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.stub_chain(:site_domains, :build).and_return(site_domain)
        site_domain.should_receive(:save).and_return(false)

        post :create, :affiliate_id => affiliate.id, :site_domain => { :domain => 'usa.gov' }
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:site_domain).with(site_domain) }
      it { should render_template(:new) }
    end
  end

  describe "#edit" do
    context "when logged in as an affiliate manager who does not have access to the domain" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:site_domains, :find_by_id).and_return(nil)

        get :edit, :affiliate_id => affiliate.id, :id => '1001'
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should redirect_to(affiliate_site_domains_path(affiliate)) }
    end

    context "when logged in as an affiliate manager who has access to the domain" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:site_domain) { mock_model(SiteDomain) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:site_domains, :find_by_id).and_return(site_domain)

        get :edit, :affiliate_id => affiliate.id, :id => '1001'
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:site_domain).with(site_domain) }
      it { should respond_with(:success) }
    end
  end

  describe "#update" do
    context "when logged in as an affiliate manager who does not have access to the domain" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:site_domains, :find_by_id).and_return(nil)

        put :update, :affiliate_id => affiliate.id, :id => '1001', :site_domain => { :domain => 'usa.gov' }
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should redirect_to(affiliate_site_domains_path(affiliate)) }
    end

    context "when logged in as an affiliate manager who has access to the domain and the domain was successfully updated" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:site_domain) { mock_model(SiteDomain) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:site_domains, :find_by_id).and_return(site_domain)
        affiliate.should_receive(:update_site_domain).with(site_domain, { 'domain' => 'usa.gov' }).and_return(true)

        put :update, :affiliate_id => affiliate.id, :id => '1001', :site_domain => { :domain => 'usa.gov' }
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:site_domain).with(site_domain) }
      it { should redirect_to affiliate_site_domains_path(affiliate) }
      it { should set_the_flash }
    end

    context "when logged in as an affiliate manager who has access to the domain and failed to update the domain" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:site_domain) { mock_model(SiteDomain) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:site_domains, :find_by_id).and_return(site_domain)
        affiliate.should_receive(:update_site_domain).with(site_domain, { 'domain' => 'usa.gov' }).and_return(false)

        put :update, :affiliate_id => affiliate.id, :id => '1001', :site_domain => { :domain => 'usa.gov' }
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:site_domain).with(site_domain) }
      it { should render_template(:edit) }
    end
  end

  describe "#destroy" do
    context "when logged in as an affiliate manager who does not have access to the domain" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:site_domains, :find_by_id).and_return(nil)

        delete :destroy, :affiliate_id => affiliate.id, :id => '1001'
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should redirect_to(affiliate_site_domains_path(affiliate)) }
    end

    context "when logged in as an affiliate manager who has access to the domain" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:site_domain) { mock_model(SiteDomain) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:site_domains, :find_by_id).and_return(site_domain)
        site_domain.should_receive(:destroy)

        delete :destroy, :affiliate_id => affiliate.id, :id => '1001'
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:site_domain).with(site_domain) }
      it { should redirect_to affiliate_site_domains_path(affiliate) }
      it { should set_the_flash }
    end
  end

  describe "#bulk_new" do
    context "when logged in as an affiliate manager who belongs to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        get :bulk_new, :affiliate_id => affiliate.id
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should respond_with(:success) }
    end
  end

  describe "#upload" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:site_domains_file) { mock("site_domains_file") }

    context "when logged in as an affiliate manager who owns the affiliate and successfully bulk upload domains" do
      before do
        UserSession.create(users(:affiliate_manager))
        SiteDomain.should_receive(:process_file).with(affiliate, site_domains_file.to_s).and_return({:success => true, :added => 5})
        post :upload, :affiliate_id => affiliate.id, :site_domains => site_domains_file
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should redirect_to(affiliate_site_domains_path(affiliate)) }
      it { should set_the_flash.to(/Successfully uploaded 5 domains./) }
    end

    context "when logged in as an affiliate manager who owns the affiliate and failed to bulk upload domains" do
      before do
        UserSession.create(users(:affiliate_manager))
        SiteDomain.should_receive(:process_file).with(affiliate, site_domains_file.to_s).and_return({:success => false, :error_message => 'error'})
        post :upload, :affiliate_id => affiliate.id, :site_domains => site_domains_file
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should set_the_flash.now.to(/error/) }
      it { should render_template(:bulk_new) }
    end
  end
end
