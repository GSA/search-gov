require 'spec/spec_helper'

describe Admin::FeaturedCollectionsController do
  fixtures :users, :featured_collections
  before do
    activate_authlogic
  end

  describe "#index" do
    context "when affiliate admin is not logged in" do
      before do
        get :index
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate admin" do
      let(:current_user) { users(:affiliate_admin) }
      let(:featured_collections) { mock('featured collections') }
      let(:featured_collections_with_paginate) { mock('Featured Collections with paginate') }

      before do
        UserSession.create(current_user)
        FeaturedCollection.should_receive(:where).with(:affiliate_id => nil).and_return(featured_collections)
        featured_collections.should_receive(:paginate).with(:per_page => FeaturedCollection.per_page, :page => nil).and_return(featured_collections_with_paginate)

        get :index
      end

      it { should assign_to(:page_title).with_kind_of(String) }
      it { should assign_to(:featured_collections).with(featured_collections_with_paginate) }
      it { should respond_with(:success) }
    end
  end

  describe "#new" do
    context "when affiliate admin is not logged in" do
      before do
        get :new
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate admin" do
      let(:current_user) { users(:affiliate_admin) }
      let(:featured_collection) { mock('featured_collection') }
      let(:featured_collection_keywords) { mock('keywords') }
      let(:featured_collection_links) { mock('links') }

      before do
        UserSession.create(current_user)

        FeaturedCollection.should_receive(:new).and_return(featured_collection)
        featured_collection.should_receive(:featured_collection_keywords).twice.and_return(featured_collection_keywords)
        featured_collection_keywords.should_receive(:blank?).and_return(true)
        featured_collection_keywords.should_receive(:build)
        featured_collection.should_receive(:featured_collection_links).exactly(3).times.and_return(featured_collection_links)
        featured_collection_links.should_receive(:size).and_return(0)
        featured_collection_links.should_receive(:build).twice

        get :new
      end

      it { should assign_to(:page_title).with_kind_of(String) }
      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should respond_with(:success) }
    end
  end

  describe "#create" do
    context "when affiliate admin is not logged in" do
      before do
        post :create, :featured_collection => {}
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate admin" do
      let(:current_user) { users(:affiliate_admin) }
      let(:featured_collection) { mock_model(FeaturedCollection) }

      before do
        UserSession.create(current_user)

        FeaturedCollection.should_receive(:new).and_return(featured_collection)
        featured_collection.should_receive(:save).and_return(true)

        post :create, :featured_collection => { :title => 'aTitle', :title_url => 'aTitleUrl', :locale => 'en', :status => 'Draft' }
      end

      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should set_the_flash }
      it { should redirect_to([:admin, featured_collection]) }
    end

    context "when logged in as an affiliate admin and failed to create a featured collection" do
      let(:current_user) { users(:affiliate_admin) }
      let(:featured_collection) { mock_model(FeaturedCollection) }
      let(:featured_collection_keywords) { mock('keywords') }
      let(:featured_collection_links) { mock('links') }

      before do
        UserSession.create(current_user)

        FeaturedCollection.should_receive(:new).and_return(featured_collection)
        featured_collection.should_receive(:save).and_return(false)

        featured_collection.should_receive(:featured_collection_keywords).twice.and_return(featured_collection_keywords)
        featured_collection_keywords.should_receive(:blank?).and_return(true)
        featured_collection_keywords.should_receive(:build)
        featured_collection.should_receive(:featured_collection_links).exactly(3).times.and_return(featured_collection_links)
        featured_collection_links.should_receive(:size).and_return(0)
        featured_collection_links.should_receive(:build).twice

        post :create, :featured_collection => { :title => 'aTitle', :title_url => 'aTitleUrl', :locale => 'en', :status => 'Draft' }
      end

      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should assign_to(:page_title).with_kind_of(String) }
      it { should render_template(:new) }
    end

    context "when logged in as an affiliate admin entered one keyword, one link and failed to create a featured collection" do
      let(:current_user) { users(:affiliate_admin) }
      let(:featured_collection) { mock_model(FeaturedCollection) }
      let(:featured_collection_keywords) { mock('keywords') }
      let(:featured_collection_links) { mock('links') }

      before do
        UserSession.create(current_user)

        FeaturedCollection.should_receive(:new).and_return(featured_collection)
        featured_collection.should_receive(:save).and_return(false)

        featured_collection.should_receive(:featured_collection_keywords).and_return(featured_collection_keywords)
        featured_collection_keywords.should_receive(:blank?).and_return(false)
        featured_collection_keywords.should_not_receive(:build)
        featured_collection.should_receive(:featured_collection_links).exactly(2).times.and_return(featured_collection_links)
        featured_collection_links.should_receive(:size).and_return(1)
        featured_collection_links.should_receive(:build)

        post :create,
             :featured_collection => { :title => 'aTitle', :title_url => 'aTitleUrl', :locale => 'en', :status => 'Draft' },
             :featured_collection_keywords_attributes => { '0' => { :value => "weather" } },
             :featured_collection_links_attributes => { '0' => { :title => 'link title', :url => 'link url' } }
      end

      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should assign_to(:page_title).with_kind_of(String) }
      it { should render_template(:new) }
    end

  end

  describe "#show" do
    let(:current_user) { users(:affiliate_admin) }
    let(:featured_collection) { mock_model(FeaturedCollection) }
    let(:affiliate_featured_collection) { featured_collections(:basic) }

    context "when affiliate admin is not logged in" do
      before do
        get :show, :id => featured_collection.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate admin but the featured collection belongs to an affiliate" do
      before do
        UserSession.create(current_user)
        get :show, :id => affiliate_featured_collection.id
      end

      it { should redirect_to(admin_featured_collections_path) }
    end

    context "when logged in as an affiliate admin" do
      before do
        UserSession.create(current_user)
        FeaturedCollection.stub_chain(:where, :first).and_return(featured_collection)
        get :show, :id => featured_collection.id.to_s
      end

      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should assign_to(:page_title).with_kind_of(String) }
    end
  end

  describe "#edit" do
    let(:current_user) { users(:affiliate_admin) }
    let(:featured_collection) { mock('featured collection', { :id => 1 }) }
    let(:affiliate_featured_collection) { featured_collections(:basic) }
    let(:featured_collection_keywords) { mock('keywords') }
    let(:featured_collection_links) { mock('links') }

    context "when affiliate admin is not logged in" do
      before do
        get :edit, :id => featured_collection.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate admin but the featured collection belongs to an affiliate" do
      before do
        UserSession.create(current_user)
        get :edit, :id => affiliate_featured_collection.id
      end

      it { should redirect_to(admin_featured_collections_path) }
    end

    context "when logged in as an affiliate admin" do
      before do
        UserSession.create(current_user)

        FeaturedCollection.stub_chain(:where, :first).and_return(featured_collection)

        featured_collection.should_receive(:featured_collection_keywords).twice.and_return(featured_collection_keywords)
        featured_collection_keywords.should_receive(:blank?).and_return(true)
        featured_collection_keywords.should_receive(:build)
        featured_collection.should_receive(:featured_collection_links).exactly(3).times.and_return(featured_collection_links)
        featured_collection_links.should_receive(:size).and_return(0)
        featured_collection_links.should_receive(:build).twice

        get :edit, :id => featured_collection.id
      end

      it { should assign_to(:page_title).with_kind_of(String) }
      it { should assign_to(:featured_collection).with(featured_collection) }
    end
  end

  describe "#update" do
    let(:current_user) { users(:affiliate_admin) }
    let(:featured_collection) { mock_model(FeaturedCollection, { :id => 100, :model_name => FeaturedCollection.class.name }) }
    let(:affiliate_featured_collection) { featured_collections(:basic) }
    let(:featured_collection_keywords) { mock('keywords') }
    let(:featured_collection_links) { mock('links') }

    context "when affiliate admin is not logged in" do
      before do
        post :update, :id => featured_collection.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate admin but the featured collection belongs to an affiliate" do
      before do
        UserSession.create(current_user)
        post :update, :id => affiliate_featured_collection.id
      end

      it { should redirect_to(admin_featured_collections_path) }
    end

    context "when logged in as an affiliate admin and successfully update a featured collection" do
      before do
        UserSession.create(current_user)

        FeaturedCollection.stub_chain(:where, :first).and_return(featured_collection)
        featured_collection.should_receive(:destroy_and_update_attributes).and_return(true)

        post :update, :id => featured_collection.id, :featured_collection => { "title" => "hello" }
      end

      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should set_the_flash }
      it { should redirect_to([:admin, featured_collection]) }
    end

    context "when logged in as an affiliate admin and failed to update a featured collection" do
      before do
        UserSession.create(current_user)

        FeaturedCollection.stub_chain(:where, :first).and_return(featured_collection)
        featured_collection.should_receive(:destroy_and_update_attributes).and_return(false)

        featured_collection.should_receive(:featured_collection_keywords).twice.and_return(featured_collection_keywords)
        featured_collection_keywords.should_receive(:blank?).and_return(true)
        featured_collection_keywords.should_receive(:build)
        featured_collection.should_receive(:featured_collection_links).exactly(3).times.and_return(featured_collection_links)
        featured_collection_links.should_receive(:size).and_return(0)
        featured_collection_links.should_receive(:build).twice

        post :update, :id => featured_collection.id, :featured_collection => { "title" => "" }
      end

      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should assign_to(:page_title).with_kind_of(String) }
      it { should render_template(:edit) }
    end
  end

  describe "#destroy" do
    let(:current_user) { users(:affiliate_admin) }
    let(:featured_collection) { mock_model(FeaturedCollection) }
    let(:affiliate_featured_collection) { featured_collections(:basic) }

    context "when affiliate admin is not logged in" do
      before do
        delete :destroy, :id => featured_collection.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate admin but the featured collection belongs to an affiliate" do
      before do
        UserSession.create(current_user)
        post :destroy, :id => affiliate_featured_collection.id
      end

      it { should redirect_to(admin_featured_collections_path) }
    end

    context "when logged in as an affiliate admin and successfully delete a featured collection" do
      before do
        UserSession.create(current_user)
        FeaturedCollection.stub_chain(:where, :first).and_return(featured_collection)
        featured_collection.should_receive(:destroy)

        delete :destroy, :id => featured_collection.id
      end

      it { should redirect_to(admin_featured_collections_path) }
      it { should set_the_flash }
    end
  end
end
