require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Admin::TopSearchesController do
  fixtures :users

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

    describe "GET index" do
      it "should assign page title" do
        top_searches = [mock_model(TopSearch)]
        TopSearch.should_receive(:find).and_return(top_searches)
        active_top_searches = []
        TopSearch.should_receive(:find_active_entries).and_return(active_top_searches)
        get :index
        assigns[:top_searches].should == top_searches
        assigns[:active_top_searches].should == active_top_searches
        assigns[:page_title].should == "Top Searches"
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
          TopSearch.stub(:find_by_position).with(index).and_return(@top_searches[index - 1])
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
