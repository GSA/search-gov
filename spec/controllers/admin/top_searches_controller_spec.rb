require 'spec/spec_helper'

describe Admin::TopSearchesController do
  fixtures :users
  before do
    activate_authlogic
  end

  it "should require login" do
    get :index
    response.should redirect_to(login_path)
  end

  context "a logged in user" do
    before do
      @user = users(:affiliate_admin)
      UserSession.create(@user)
    end

    describe "GET index" do
      it "should assign page title" do
        top_searches = [mock_model(TopSearch)]
        top_searches.stub!(:order).and_return top_searches
        TopSearch.should_receive(:where).and_return(top_searches)
        active_top_searches = []
        TopSearch.should_receive(:find_active_entries).and_return(active_top_searches)
        get :index
        assigns[:top_searches].should == top_searches
        assigns[:active_top_searches].should == active_top_searches
        assigns[:page_title].should == "Top Searches"
      end
      
      context "when rendering the index page" do
        render_views
        
        it "should show the page and form fields even if there are no top searches with affiliate_id=nil" do
          get :index
          response.body.should have_selector("input[id='query5']")
        end
      end
    end

    describe "POST create" do
      before do
        @top_searches = []
        1.upto(5) do |index|
          top_search = mock_model(TopSearch)
          top_search.should_receive(:query=)
          top_search.should_receive(:url=)
          top_search.should_receive(:save)
          @top_searches << top_search
          TopSearch.stub(:find_or_initialize_by_position_and_affiliate_id).with(index, nil).and_return(@top_searches[index - 1])
        end
      end

      it "should assign top searches on create" do
        post :create
        assigns[:top_searches].should == @top_searches
      end

      it "should render #index on create" do
        post :create
        response.should redirect_to admin_top_searches_path
      end

      it "should assign page title on create" do
        post :create
        assigns[:page_title].should == "Top Searches"
      end
    end
  end
end
