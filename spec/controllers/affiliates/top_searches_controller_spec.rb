require 'spec/spec_helper'

describe Affiliates::TopSearchesController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
    @user = users(:affiliate_manager)
    @affiliate = affiliates(:basic_affiliate)
  end

  it "should require login" do
    get :index, :affiliate_id => @affiliate.id
    response.should redirect_to(login_path)
  end

  context "a logged in user" do
    before do
      UserSession.create(@user)
    end

    describe "GET index" do
      context "when there are some Top Searches for an affiliate" do
        before do
          TopSearch.destroy_all
          1.upto(3) do |index|
            TopSearch.create!(:query => 'top search', :position => index, :affiliate => @affiliate)
          end
        end

        it "should assign page title" do
          get :index, :affiliate_id => @affiliate.id
          assigns[:top_searches].should == @affiliate.top_searches
          assigns[:active_top_searches].should == @affiliate.active_top_searches
        end
      end

      context "when rendering the index page" do
        render_views

        it "should show the page and form fields even if there are no top searches for the affiliate" do
          @affiliate.top_searches.destroy_all
          get :index, :affiliate_id => @affiliate.id
          response.should render_template('admin/top_searches/index')
          response.body.should have_selector("input[id='query5']")
        end
      end
    end

    describe "POST create" do
      it "should assign top searches on create" do
        post :create, :affiliate_id => @affiliate.id, :query1 => 'top search'
        assigns[:top_searches].should == @affiliate.top_searches
      end

      it "should render #index on create" do
        post :create, :affiliate_id => @affiliate.id
        response.should redirect_to affiliate_top_searches_path
      end

      it "should assign page title on create" do
        post :create, :affiliate_id => @affiliate.id
      end

      it "should update the top searches label if provided" do
        @affiliate.top_searches_label.should_not == 'New Label'
        post :create, :affiliate_id => @affiliate.id, :top_searches_label => 'New Label'
        @affiliate.reload
        @affiliate.top_searches_label.should == 'New Label'
      end

      it "should set the label to 'Search Trends' if none is provided" do
        @affiliate.update_attributes(:top_searches_label => 'Something else')
        post :create, :affiliate_id => @affiliate.id
        @affiliate.reload
        @affiliate.top_searches_label.should == 'Search Trends'
      end
    end
  end
end
