require 'spec_helper'

describe Affiliates::BoostedContentsController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
    BoostedContent.destroy_all
    BoostedContent.reindex
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
      let(:boosted_contents) { mock('Boosted Contents') }
      let(:boosted_contents_with_paginate) { mock('Boosted Contents with paginate') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:boosted_contents).and_return(boosted_contents)
        boosted_contents.should_receive(:paginate).with(:per_page => BoostedContent.per_page, :page => nil, :order => 'updated_at DESC, id DESC').and_return(boosted_contents_with_paginate)

        get :index, :affiliate_id => affiliate.id
      end

      it { should assign_to(:title).with_kind_of(String) }
      it { should assign_to(:boosted_contents).with(boosted_contents_with_paginate) }
      it { should respond_with(:success) }
    end
  end

  describe "do GET on #new" do
    context "when affiliate manager is not logged in" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        get :new, :affiliate_id => affiliate.id
      end

      it { should redirect_to(login_path) }
     end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
        get :new, :affiliate_id => affiliates(:power_affiliate).id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:another_affiliate) { affiliates(:another_affiliate) }

      before do
        UserSession.create(users(:affiliate_manager))
        get :new, :affiliate_id => another_affiliate.id
      end

      it { should redirect_to(home_page_path) }
    end

  end

  describe "create" do
    it "should require affiliate login" do
      post :create, :affiliate_id => affiliates(:power_affiliate).id
      response.should redirect_to(login_path)
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:another_affiliate) { affiliates(:another_affiliate) }

      before do
        UserSession.create(users(:affiliate_manager))
        post :create, :affiliate_id => another_affiliate.id, :boosted_content => {:url => "a url", :title => "a title", :description => "a description", :status => 'active'}
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully added a boosted content" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:boosted_content) { mock_model(BoostedContent) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.stub_chain(:boosted_contents, :build).and_return(boosted_content)
        boosted_content.should_receive(:save).and_return(true)
        Sunspot.should_receive(:index).with(boosted_content)

        post :create, :affiliate_id => affiliate.id, :boosted_content => {:url => "a url", :title => "a title", :description => "a description", :status => 'active'}
      end

      it { should assign_to(:boosted_content).with(boosted_content) }
      it { should set_the_flash }
      it { should redirect_to([affiliate, boosted_content]) }
    end

  end

  describe "#show" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:boosted_content) { mock_model(BoostedContent, { :title => 'aBoostedContent'}) }
    let(:another_boosted_content) { mock_model(BoostedContent, { :title => 'anotherBoostedContent' }) }

    context "when affiliate manager is not logged in" do
      before do
        get :show, :affiliate_id => affiliate.id, :id => boosted_content.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :show, :affiliate_id => another_affiliate.id, :id => boosted_content.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:boosted_contents, :find_by_id).and_return(boosted_content)

        get :show, :affiliate_id => affiliate.id, :id => boosted_content.id
      end

      it { should assign_to(:boosted_content).with(boosted_content) }
      it { should assign_to(:title).with_kind_of(String) }
      it { should respond_with(:success) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the boosted content" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:boosted_contents, :find_by_id).and_return(nil)

        get :show, :affiliate_id => affiliate.id, :id => another_boosted_content.id
      end

      it { should redirect_to(affiliate_boosted_contents_path(affiliate)) }
    end
  end

  describe "#edit" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:boosted_content) { mock_model(BoostedContent, { :title => 'aBoostedContent'}) }
    let(:another_boosted_content) { mock_model(BoostedContent, { :title => 'anotherBoostedContent' }) }

    context "when affiliate manager is not logged in" do
      before do
        get :edit, :affiliate_id => affiliate.id, :id => boosted_content.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :edit, :affiliate_id => another_affiliate.id, :id => boosted_content.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the boosted content" do
      before do
        UserSession.create(current_user)
        get :edit, :affiliate_id => affiliate.id, :id => another_boosted_content.id
      end

      it { should redirect_to(affiliate_boosted_contents_path(affiliate)) }
    end
  end

  describe "#update" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:boosted_content) { mock_model(BoostedContent, { :title => 'aBoostedContent' }) }
    let(:another_boosted_content) { mock_model(BoostedContent, { :title => 'anotherBoostedContent' }) }

    context "when affiliate manager is not logged in" do
      before do
        post :update, :affiliate_id => affiliate.id, :id => boosted_content.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        post :update, :affiliate_id => another_affiliate.id, :id => boosted_content.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the boosted content" do
      before do
        UserSession.create(current_user)
        post :update, :affiliate_id => affiliate.id, :id => another_boosted_content.id
      end

      it { should redirect_to(affiliate_boosted_contents_path(affiliate)) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully update a boosted content" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:boosted_contents, :find_by_id).with(boosted_content.id.to_s).and_return(boosted_content)
        boosted_content.should_receive(:destroy_and_update_attributes).and_return(true)
        Sunspot.should_receive(:index).with(boosted_content)

        post :update, :affiliate_id => affiliate.id, :id => boosted_content.id, :boosted_content => { "title" => "hello" }
      end

      it { should assign_to(:boosted_content).with(boosted_content) }
      it { should set_the_flash }
      it { should redirect_to([affiliate, boosted_content]) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and failed to update a boosted content" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:boosted_contents, :find_by_id).with(boosted_content.id.to_s).and_return(boosted_content)
        boosted_content.should_receive(:destroy_and_update_attributes).and_return(false)

        post :update, :affiliate_id => affiliate.id, :id => boosted_content.id, :boosted_content => { "title" => "hello" }
      end

      it { should assign_to(:boosted_content).with(boosted_content) }
      it { should assign_to(:title).with_kind_of(String) }
      it { should render_template(:edit) }
    end
  end

  describe "#destroy" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:boosted_content) { mock_model(BoostedContent, { :title => 'aBoostedContent' }) }
    let(:another_boosted_content) { mock_model(BoostedContent, { :title => 'anotherBoostedContent' }) }

    context "when affiliate manager is not logged in" do
      before do
        delete :destroy, :affiliate_id => affiliate.id, :id => boosted_content.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        delete :destroy, :affiliate_id => another_affiliate.id, :id => boosted_content.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate but does not have access to the boosted content" do
      before do
        UserSession.create(current_user)
        delete :destroy, :affiliate_id => affiliate.id, :id => another_boosted_content.id
      end

      it { should redirect_to(affiliate_boosted_contents_path(affiliate)) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully delete a boosted content" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:boosted_contents, :find_by_id).with(boosted_content.id.to_s).and_return(boosted_content)
        boosted_content.should_receive(:destroy)
        boosted_content.should_receive(:solr_remove_from_index)

        delete :destroy, :affiliate_id => affiliate.id, :id => boosted_content.id
      end

      it { should redirect_to(affiliate_boosted_contents_path(affiliate)) }
      it { should set_the_flash }
    end

  end

  describe "delete all" do
    let(:current_user) { users(:affiliate_manager) }
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:another_affiliate) { affiliates(:another_affiliate) }
    let(:boosted_content) { mock_model(BoostedContent, { :title => 'aBoostedContent' }) }
    let(:another_boosted_content) { mock_model(BoostedContent, { :title => 'anotherBoostedContent' }) }

    context "when affiliate manager is not logged in" do
      before do
        post :destroy_all, :affiliate_id => affiliate.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      before do
        UserSession.create(users(:affiliate_manager))
        post :destroy_all, :affiliate_id => another_affiliate.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested and successfully delete all boosted contents" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:boosted_contents, :each).once.and_yield(boosted_content)
        boosted_content.should_receive(:delete)
        boosted_content.should_receive(:solr_remove_from_index)

        post :destroy_all, :affiliate_id => another_affiliate.id
      end

      it { should redirect_to(affiliate_boosted_contents_path(affiliate)) }
      it { should set_the_flash }
    end

  end

  describe "do GET on #bulk_new" do
    context "when affiliate manager is not logged in" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        get :bulk_new, :affiliate_id => affiliate.id
      end

      it { should redirect_to(login_path) }
     end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
        get :bulk_new, :affiliate_id => affiliates(:power_affiliate).id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:another_affiliate) { affiliates(:another_affiliate) }

      before do
        UserSession.create(users(:affiliate_manager))
        get :bulk_new, :affiliate_id => another_affiliate.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who owns the affiliate" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        get :bulk_new, :affiliate_id => affiliate.id
      end

      it { should assign_to(:title).with_kind_of(String) }
      it { should respond_with(:success) }
    end
  end

  describe "bulk upload" do
    context "when affiliate manager is not logged in" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:xml) { mock("xml_file") }

      before do
        post :bulk, :affiliate_id => affiliate.id, :bulk_upload_file => xml
      end

      it { should redirect_to(login_path) }
     end

    context "when logged in but not an affiliate manager" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:xml) { mock("xml_file") }

      before do
        UserSession.create(users(:affiliate_admin))
        post :bulk, :affiliate_id => affiliate.id, :bulk_upload_file => xml
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate" do
      let(:another_affiliate) { affiliates(:another_affiliate) }
      let(:xml) { mock("xml_file") }

      before do
        UserSession.create(users(:affiliate_manager))
        post :bulk, :affiliate_id => another_affiliate.id, :bulk_upload_file => xml
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who owns the affiliate and successfully bulk upload boosted contents" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:xml) { mock("xml_file") }

      before do
        UserSession.create(users(:affiliate_manager))
        BoostedContent.should_receive(:bulk_upload).with(affiliate, xml.to_s).and_return({:success => true, :created => 4, :updated => 2})
        post :bulk, :affiliate_id => affiliate.id, :bulk_upload_file => xml
      end

      it { should redirect_to(affiliate_boosted_contents_path(affiliate)) }
      it { should set_the_flash.to(/4 Best Bets: Text entries successfully created/) }
      it { should set_the_flash.to(/2 Best Bets: Text entries successfully updated/) }
    end

    context "when logged in as an affiliate manager who owns the affiliate and failed to bulk upload boosted contents" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:xml) { mock("xml_file") }

      before do
        UserSession.create(users(:affiliate_manager))
        BoostedContent.should_receive(:bulk_upload).with(affiliate, xml.to_s).and_return({ :success => false, :error_message => 'Your XML document could not be processed.' })
        post :bulk, :affiliate_id => affiliate.id, :bulk_upload_file => xml
      end

      it { should render_template(:bulk_new) }
      it { should set_the_flash.now.to(/could not be processed/) }
    end
  end
end
