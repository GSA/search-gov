require 'spec/spec_helper'

describe Admin::BoostedContentsController do
  fixtures :users
  before do
    activate_authlogic
    BoostedContent.destroy_all
    BoostedContent.reindex
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
      let(:boosted_contents) { mock('boosted contents') }
      let(:boosted_contents_with_paginate) { mock('boosted contents with paginate') }
      before do
        UserSession.create(current_user)
        BoostedContent.should_receive(:where).with(:affiliate_id => nil).and_return(boosted_contents)
        boosted_contents.should_receive(:paginate).
            with(:per_page => BoostedContent.per_page, :page => nil, :order => 'updated_at DESC, id DESC').
            and_return(boosted_contents_with_paginate)
        get :index
      end

      it { should assign_to(:page_title).with_kind_of(String) }
      it { should assign_to(:boosted_contents).with(boosted_contents_with_paginate) }
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
      let(:boosted_content) { mock('boosted_content') }

      before do
        UserSession.create(current_user)
        BoostedContent.should_receive(:new).with(:publish_start_on => Date.current).and_return(boosted_content)
        get :new
      end

      it { should assign_to(:parent_page_title).with_kind_of(String) }
      it { should assign_to(:page_title).with_kind_of(String) }
      it { should assign_to(:boosted_content).with(boosted_content) }
      it { should respond_with(:success) }
    end
  end

  describe "#create" do
    context "when affiliate admin is not logged in" do
      before do
        post :create, :boosted_content => {}
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate admin" do
      let(:current_user) { users(:affiliate_admin) }
      let(:boosted_content) { mock_model(BoostedContent) }

      before do
        UserSession.create(current_user)

        BoostedContent.should_receive(:new).and_return(boosted_content)
        boosted_content.should_receive(:save).and_return(true)
        Sunspot.should_receive(:index).with(boosted_content)

        post :create, :boosted_content => { :title => 'aTitle',
                                            :url => 'some.url',
                                            :description => 'some description',
                                            :locale => 'en',
                                            :status => 'active' }
      end

      it { should assign_to(:boosted_content).with(boosted_content) }
      it { should set_the_flash }
      it { should redirect_to([:admin, boosted_content]) }
    end

    context "when logged in as an affiliate admin and failed to create a boosted content" do
      let(:current_user) { users(:affiliate_admin) }
      let(:boosted_content) { mock_model(BoostedContent) }

      before do
        UserSession.create(current_user)

        BoostedContent.should_receive(:new).and_return(boosted_content)
        boosted_content.should_receive(:save).and_return(false)

        post :create, :boosted_content => { :title => 'aTitle',
                                            :url => 'some.url',
                                            :description => 'some description',
                                            :locale => 'en',
                                            :status => 'active' }
      end

      it { should assign_to(:boosted_content).with(boosted_content) }
      it { should assign_to(:page_title).with_kind_of(String) }
      it { should render_template(:new) }
    end
  end

  describe "#show" do
    let(:current_user) { users(:affiliate_admin) }
    let(:boosted_content) { mock_model(BoostedContent) }
    let(:affiliate_boosted_content) { mock_model(BoostedContent)}

    context "when affiliate admin is not logged in" do
      before do
        get :show, :id => boosted_content.id
      end

      it { should redirect_to(login_path) }

    end

    context "when logged in as an affiliate admin and the boosted content belongs to an affiliate" do
      let(:empty_boosted_contents) { mock('empty boosted contents')}
      before do
        UserSession.create(current_user)
        BoostedContent.should_receive(:where).with(:id => affiliate_boosted_content.id, :affiliate_id => nil).
            and_return(empty_boosted_contents)
        empty_boosted_contents.should_receive(:first).and_return(nil)
        get :show, :id => affiliate_boosted_content.id
      end

      it { should redirect_to(admin_boosted_contents_path) }
    end

    context "when logged in as an affiliate admin and the boosted content belongs to Search.USA.gov" do
      let(:boosted_content_array) { mock('boosted content array') }
      before do
        UserSession.create(current_user)
        BoostedContent.should_receive(:where).with(:id => boosted_content.id, :affiliate_id => nil).
            and_return(boosted_content_array)
        boosted_content_array.should_receive(:first).and_return(boosted_content)
        get :show, :id => boosted_content.id
      end

      it { should assign_to(:boosted_content).with(boosted_content) }
      it { should assign_to(:parent_page_title).with_kind_of(String) }
      it { should assign_to(:page_title).with_kind_of(String) }
    end
  end

  describe "#edit" do
    let(:current_user) { users(:affiliate_admin) }
    let(:boosted_content) { mock_model(BoostedContent, { :title => 'aBoostedContent'}) }
    let(:affiliate_boosted_content) { mock_model(BoostedContent)}

    context "when affiliate admin is not logged in" do
      before do
        get :edit, :id => boosted_content.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate admin and the boosted content belongs to an affiliate" do
      let(:empty_boosted_contents) { mock('empty boosted contents')}
      before do
        UserSession.create(current_user)
        BoostedContent.should_receive(:where).with(:id => affiliate_boosted_content.id, :affiliate_id => nil).
            and_return(empty_boosted_contents)
        empty_boosted_contents.should_receive(:first).and_return(nil)
        get :edit, :id => affiliate_boosted_content.id
      end

      it { should redirect_to(admin_boosted_contents_path) }
    end

    context "when logged in as an affiliate admin and the boosted content belongs to Search.USA.gov" do
      let(:boosted_content_array) { mock('boosted content array') }
      before do
        UserSession.create(current_user)
        BoostedContent.should_receive(:where).with(:id => boosted_content.id, :affiliate_id => nil).
            and_return(boosted_content_array)
        boosted_content_array.should_receive(:first).and_return(boosted_content)
        get :edit, :id => boosted_content.id
      end

      it { should assign_to(:boosted_content).with(boosted_content) }
      it { should assign_to(:parent_page_title).with_kind_of(String) }
      it { should assign_to(:page_title).with_kind_of(String) }
    end
  end

  describe "#update" do
    let(:current_user) { users(:affiliate_admin) }
    let(:boosted_content) { mock_model(BoostedContent) }
    let(:affiliate_boosted_content) { mock_model(BoostedContent)}

    context "when affiliate admin is not logged in" do
      before do
        put :update, :id => boosted_content.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate admin and the boosted content belongs to an affiliate" do
      let(:empty_boosted_contents) { mock('empty boosted contents')}
      before do
        UserSession.create(current_user)
        BoostedContent.should_receive(:where).with(:id => affiliate_boosted_content.id, :affiliate_id => nil).
            and_return(empty_boosted_contents)
        empty_boosted_contents.should_receive(:first).and_return(nil)
        put :update, :id => affiliate_boosted_content.id, :boosted_content => { :title => 'aTitle' }
      end

      it { should redirect_to(admin_boosted_contents_path) }
    end

    context "when logged in as an affiliate admin and successfully update the boosted content" do
      let(:boosted_content_array) { mock('boosted content array') }
      before do
        UserSession.create(current_user)
        BoostedContent.should_receive(:where).with(:id => boosted_content.id, :affiliate_id => nil).
            and_return(boosted_content_array)
        boosted_content_array.should_receive(:first).and_return(boosted_content)
        boosted_content.should_receive(:update_attributes).and_return(true)
        Sunspot.should_receive(:index).with(boosted_content)
        put :update, :id => boosted_content.id, :boosted_content => { :title => 'aTitle' }
      end

      it { should assign_to(:boosted_content).with(boosted_content) }
      it { should set_the_flash }
      it { should redirect_to [:admin, boosted_content] }
    end

    context "when logged in as an affiliate admin and failed to update the boosted content" do
      let(:boosted_content_array) { mock('boosted content array') }
      before do
        UserSession.create(current_user)
        BoostedContent.should_receive(:where).with(:id => boosted_content.id, :affiliate_id => nil).
            and_return(boosted_content_array)
        boosted_content_array.should_receive(:first).and_return(boosted_content)
        boosted_content.should_receive(:update_attributes).and_return(false)
        post :update, :id => boosted_content.id, :boosted_content => { :title => 'aTitle' }
      end

      it { should assign_to(:boosted_content).with(boosted_content) }
      it { should assign_to(:parent_page_title).with_kind_of(String)}
      it { should assign_to(:page_title).with_kind_of(String)}
    end
  end

  describe "#destroy" do
    let(:current_user) { users(:affiliate_admin) }
    let(:boosted_content) { mock_model(BoostedContent) }
    let(:affiliate_boosted_content) { mock_model(BoostedContent)}

    context "when affiliate admin is not logged in" do
      before do
        delete :destroy, :id => boosted_content.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate admin and the boosted content belongs to an affiliate" do
      let(:empty_boosted_contents) { mock('empty boosted contents')}

      before do
        UserSession.create(current_user)
        BoostedContent.should_receive(:where).with(:id => affiliate_boosted_content.id, :affiliate_id => nil).
            and_return(empty_boosted_contents)
        empty_boosted_contents.should_receive(:first).and_return(nil)
        delete :destroy, :id => affiliate_boosted_content.id
      end

      it { should redirect_to(admin_boosted_contents_path) }
    end

    context "when logged in as an affiliate admin and successfully delete the boosted content" do
      let(:boosted_content_array) { mock('boosted content array') }
      before do
        UserSession.create(current_user)
        BoostedContent.should_receive(:where).with(:id => boosted_content.id, :affiliate_id => nil).
            and_return(boosted_content_array)
        boosted_content_array.should_receive(:first).and_return(boosted_content)
        boosted_content.should_receive(:destroy)
        boosted_content.should_receive(:solr_remove_from_index)
        delete :destroy, :id => boosted_content.id
      end

      it { should assign_to(:boosted_content).with(boosted_content) }
      it { should set_the_flash }
      it { should redirect_to admin_boosted_contents_path }
    end

    context "when working with solr index" do
      before do
        @boosted_content = BoostedContent.create!(:url => "a url",
                                                  :title => "a title",
                                                  :description => "a description",
                                                  :locale => 'en',
                                                  :status => 'active',
                                                  :publish_start_on => Date.current)
        UserSession.create(current_user)
        Sunspot.index(@boosted_content)
        Sunspot.commit
        BoostedContent.solr_search_ids { with :affiliate_name, Affiliate::USAGOV_AFFILIATE_NAME; paginate(:page => 1, :per_page => 10) }.should_not be_empty

        delete :destroy, :id => @boosted_content.id
      end

      specify { BoostedContent.where(:affiliate_id => nil).should be_empty }
      specify { BoostedContent.solr_search_ids { with :affiliate_name, Affiliate::USAGOV_AFFILIATE_NAME; paginate(:page => 1, :per_page => 10) }.should be_empty }
    end
  end

  describe "#bulk_new" do
    let(:current_user) { users(:affiliate_admin) }

    context "when affiliate admin is not logged in" do
      before do
        get :bulk_new
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate admin" do
      before do
        UserSession.create(current_user)
        get :bulk_new
      end

      it { should assign_to(:parent_page_title).with_kind_of(String) }
      it { should assign_to(:page_title).with_kind_of(String) }
      it { should respond_with(:success) }
    end
  end

  describe "bulk upload" do
    let(:current_user) { users(:affiliate_admin) }

    context "when affiliate admin is not logged in" do
      before do
        get :bulk_new
      end

      it { should redirect_to(login_path) }
     end

    context "when logged in as an affiliate admin and successfully bulk upload boosted contents" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:xml) { mock("xml_file") }

      before do
        UserSession.create(users(:affiliate_admin))
        BoostedContent.should_receive(:process_boosted_content_bulk_upload_for).with(nil, xml).and_return({:success => true, :created => 4, :updated => 2})
        post :bulk, :bulk_upload_file => xml
      end

      it { should redirect_to(admin_boosted_contents_path) }
      it { should set_the_flash.to(/4 Best Bets: Text entries successfully created/) }
      it { should set_the_flash.to(/2 Best Bets: Text entries successfully updated/) }
    end

    context "when logged in as an affiliate admin and failed to bulk upload boosted contents" do
      let(:xml) { mock("xml_file") }

      before do
        UserSession.create(users(:affiliate_admin))
        BoostedContent.should_receive(:process_boosted_content_bulk_upload_for).with(nil, xml).and_return({ :success => false, :error_message => 'Your XML document could not be processed.' })
        post :bulk, :bulk_upload_file => xml
      end

      it { should assign_to(:parent_page_title).with_kind_of(String) }
      it { should assign_to(:page_title).with_kind_of(String) }
      it { should set_the_flash.to(/could not be processed/) }
      it { should render_template(:bulk_new) }
    end
  end
end
