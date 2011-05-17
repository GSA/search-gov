require 'spec/spec_helper'

describe Admin::SaytSuggestionsUploadsController do
  fixtures :users
  render_views

  before do
    activate_authlogic
  end

  it "should require login" do
    get :new
    response.should redirect_to(login_path)
  end

  context "a logged in user" do
    before do
      @user = users(:affiliate_admin)
      UserSession.create(@user)
    end

    describe "GET new" do
      it "should assign page title" do
        get :new
        assigns[:page_title].should == "SAYT Suggestions Bulk Upload"
      end
    end

    describe "POST create" do
      it "should render #new on errors" do
        SaytSuggestion.should_receive(:process_sayt_suggestion_txt_upload).with("file_content").and_return(nil)
        post :create, :txtfile => "file_content"
        response.should render_template(:new)
      end

      it "should assign page title on errors" do
        SaytSuggestion.should_receive(:process_sayt_suggestion_txt_upload).with("file_content").and_return(nil)
        post :create, :txtfile => "file_content"
        assigns[:page_title].should == "SAYT Suggestions Bulk Upload"
      end
    end
  end
end
