require 'spec/spec_helper'

describe Affiliates::FeaturedCollectionsController do
  fixtures :affiliates, :users, :featured_collections
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
      let(:featured_collections) { mock('Featured Collections') }
      let(:featured_collections_with_paginate) { mock('Featured Collections with paginate') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:featured_collections).and_return(featured_collections)
        featured_collections.should_receive(:paginate).with(:all, :per_page => FeaturedCollection.per_page, :page => nil, :order => 'updated_at DESC, id DESC').and_return(featured_collections_with_paginate)

        get :index, :affiliate_id => affiliate.id
      end

      it { should assign_to(:title).with_kind_of(String) }
      it { should assign_to(:featured_collections).with(featured_collections_with_paginate) }
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
      let(:featured_collection) { mock('featured_collection') }
      let(:featured_collection_keywords) { mock('keywords') }
      let(:featured_collection_links) { mock('links') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:featured_collections, :build).with(:publish_start_on => Date.current).and_return(featured_collection)

        featured_collection.should_receive(:featured_collection_keywords).twice.and_return(featured_collection_keywords)
        featured_collection_keywords.should_receive(:blank?).and_return(true)
        featured_collection_keywords.should_receive(:build)
        featured_collection.should_receive(:featured_collection_links).exactly(3).times.and_return(featured_collection_links)
        featured_collection_links.should_receive(:size).and_return(0)
        featured_collection_links.should_receive(:build).twice

        get :new, :affiliate_id => affiliate.id
      end

      it { should assign_to(:title).with_kind_of(String) }
      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should respond_with(:success) }
    end
  end

  describe "#create" do
    context "when affiliate manager is not logged in" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        post :create, :affiliate_id => affiliate.id, :featured_collection => {}
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:another_affiliate) { affiliates(:another_affiliate) }

      before do
        UserSession.create(users(:affiliate_manager))
        post :create, :affiliate_id => another_affiliate.id, :featured_collection => {}
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully create a featured collection" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:featured_collection) { featured_collections(:basic) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.stub_chain(:featured_collections, :build).and_return(featured_collection)
        featured_collection.should_receive(:save).and_return(true)

        post :create, :affiliate_id => affiliate.id, :featured_collection => { :title => 'aTitle', :title_url => 'aTitleUrl', :locale => 'en', :status => 'Draft' }
      end

      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should set_the_flash }
      it { should redirect_to([affiliate, featured_collection]) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and failed to create a featured collection" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:featured_collection) { mock('featured_collection') }
      let(:featured_collection_keywords) { mock('keywords') }
      let(:featured_collection_links) { mock('links') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.stub_chain(:featured_collections, :build).and_return(featured_collection)
        featured_collection.should_receive(:save).and_return(false)

        featured_collection.should_receive(:featured_collection_keywords).twice.and_return(featured_collection_keywords)
        featured_collection_keywords.should_receive(:blank?).and_return(true)
        featured_collection_keywords.should_receive(:build)
        featured_collection.should_receive(:featured_collection_links).exactly(3).times.and_return(featured_collection_links)
        featured_collection_links.should_receive(:size).and_return(0)
        featured_collection_links.should_receive(:build).twice

        post :create, :affiliate_id => affiliate.id, :featured_collection => { :title => 'aTitle', :title_url => 'aTitleUrl', :locale => 'en', :status => 'Draft' }
      end

      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should assign_to(:title).with_kind_of(String) }
      it { should render_template(:new) }
    end

    context "when logged in as an affiliate manager entered one keyword, one link and failed to create a featured collection" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:featured_collection) { mock('featured_collection') }
      let(:featured_collection_keywords) { mock('keywords') }
      let(:featured_collection_links) { mock('links') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.stub_chain(:featured_collections, :build).and_return(featured_collection)
        featured_collection.should_receive(:save).and_return(false)

        featured_collection.should_receive(:featured_collection_keywords).and_return(featured_collection_keywords)
        featured_collection_keywords.should_receive(:blank?).and_return(false)
        featured_collection_keywords.should_not_receive(:build)
        featured_collection.should_receive(:featured_collection_links).exactly(2).times.and_return(featured_collection_links)
        featured_collection_links.should_receive(:size).and_return(1)
        featured_collection_links.should_receive(:build)

        post :create, :affiliate_id => affiliate.id,
             :featured_collection => { :title => 'aTitle', :title_url => 'aTitleUrl', :locale => 'en', :status => 'Draft' },
             :featured_collection_keywords_attributes => { '0' => { :value => "weather" } },
             :featured_collection_links_attributes => { '0' => { :title => 'link title', :url => 'link url' } }
      end

      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should assign_to(:title).with_kind_of(String) }
      it { should render_template(:new) }
    end

  end

  describe "#show" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:featured_collection) { featured_collections(:basic) }
    let(:another_featured_collection) { featured_collections(:another) }

    context "when affiliate manager is not logged in" do
      before do
        get :show, :affiliate_id => affiliate.id, :id => featured_collection.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :show, :affiliate_id => another_affiliate.id, :id => featured_collection.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested" do
      before do
        UserSession.create(current_user)
        get :show, :affiliate_id => affiliate.id, :id => featured_collection.id
      end

      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should assign_to(:title).with_kind_of(String) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the featured collection" do
      before do
        UserSession.create(current_user)
        get :show, :affiliate_id => affiliate.id, :id => another_featured_collection.id
      end

      it { should redirect_to(affiliate) }
    end

  end

  describe "#edit" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:featured_collection) { featured_collections(:basic) }
    let(:another_featured_collection) { featured_collections(:another) }
    let(:featured_collection_keywords) { mock('keywords') }
    let(:featured_collection_links) { mock('links') }

    context "when affiliate manager is not logged in" do
      before do
        get :edit, :affiliate_id => affiliate.id, :id => featured_collection.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :edit, :affiliate_id => another_affiliate.id, :id => featured_collection.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the featured collection" do
      before do
        UserSession.create(current_user)
        get :edit, :affiliate_id => affiliate.id, :id => another_featured_collection.id
      end

      it { should redirect_to(affiliate_path(affiliate)) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:featured_collections, :find_by_id).with(featured_collection.id).and_return(featured_collection)

        featured_collection.should_receive(:featured_collection_keywords).twice.and_return(featured_collection_keywords)
        featured_collection_keywords.should_receive(:blank?).and_return(true)
        featured_collection_keywords.should_receive(:build)
        featured_collection.should_receive(:featured_collection_links).exactly(3).times.and_return(featured_collection_links)
        featured_collection_links.should_receive(:size).and_return(0)
        featured_collection_links.should_receive(:build).twice

        get :edit, :affiliate_id => affiliate.id, :id => featured_collection.id
      end

      it { should assign_to(:title).with_kind_of(String) }
      it { should assign_to(:featured_collection).with(featured_collection) }
    end
  end

  describe "#update" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:featured_collection) { featured_collections(:basic) }
    let(:another_featured_collection) { featured_collections(:another) }
    let(:featured_collection_keywords) { mock('keywords') }
    let(:featured_collection_links) { mock('links') }

    context "when affiliate manager is not logged in" do
      before do
        post :update, :affiliate_id => affiliate.id, :id => featured_collection.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        post :update, :affiliate_id => another_affiliate.id, :id => featured_collection.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the featured collection" do
      before do
        UserSession.create(current_user)
        post :update, :affiliate_id => affiliate.id, :id => another_featured_collection.id
      end

      it { should redirect_to(affiliate) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully update a featured collection" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:featured_collections, :find_by_id).with(featured_collection.id).and_return(featured_collection)
        featured_collection.should_receive(:destroy_and_update_attributes).and_return(true)

        post :update, :affiliate_id => affiliate.id, :id => featured_collection.id, :featured_collection => { "title" => "hello" }
      end

      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should set_the_flash }
      it { should redirect_to([affiliate, featured_collection]) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and failed to update a featured collection" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:featured_collections, :find_by_id).with(featured_collection.id).and_return(featured_collection)
        featured_collection.should_receive(:destroy_and_update_attributes).and_return(false)

        featured_collection.should_receive(:featured_collection_keywords).twice.and_return(featured_collection_keywords)
        featured_collection_keywords.should_receive(:blank?).and_return(true)
        featured_collection_keywords.should_receive(:build)
        featured_collection.should_receive(:featured_collection_links).exactly(3).times.and_return(featured_collection_links)
        featured_collection_links.should_receive(:size).and_return(0)
        featured_collection_links.should_receive(:build).twice

        post :update, :affiliate_id => affiliate.id, :id => featured_collection.id, :featured_collection => { "title" => "" }
      end

      it { should assign_to(:featured_collection).with(featured_collection) }
      it { should assign_to(:title).with_kind_of(String) }
      it { should render_template(:edit) }
    end
  end

  describe "#destroy" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:featured_collection) { featured_collections(:basic) }
    let(:another_featured_collection) { featured_collections(:another) }

    context "when affiliate manager is not logged in" do
      before do
        delete :destroy, :affiliate_id => affiliate.id, :id => featured_collection.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        delete :destroy, :affiliate_id => another_affiliate.id, :id => featured_collection.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the featured collection" do
      before do
        UserSession.create(current_user)
        delete :destroy, :affiliate_id => affiliate.id, :id => another_featured_collection.id
      end

      it { should redirect_to(affiliate) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully delete a featured collection" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:featured_collections, :find_by_id).with(featured_collection.id).and_return(featured_collection)
        featured_collection.should_receive(:destroy)

        delete :destroy, :affiliate_id => affiliate.id, :id => featured_collection.id
      end

      it { should redirect_to(affiliate_featured_collections_path(affiliate)) }
      it { should set_the_flash }
    end
  end
end
