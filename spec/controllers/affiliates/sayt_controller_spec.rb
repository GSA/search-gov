require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Affiliates::SaytController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "#index" do
    integrate_views
    context "when logged in as an affiliate" do
      before do
        @user = users("affiliate_manager")
        UserSession.create(@user)
        @affiliate = @user.affiliates.first
      end
      
      it "should set the title" do
        get :index, :affiliate_id => @affiliate.id
        assigns[:title].should == 'Type-ahead Search - '
      end
      
      context "when the affiliate has SAYT set to affiliate-enabled" do
        before do
          @affiliate.update_attributes(:is_sayt_enabled => true, :is_affiliate_suggestions_enabled => true)
          get :index, :affiliate_id => @affiliate.id
        end
        
        it "should show the add, current entries and bulk upload portions of the page" do
          response.should have_tag("div[id=add_a_new_entry]")
          response.should have_tag("div[id=current_entries]")
          response.should have_tag("div[id=bulk_upload]")
        end
        
        it "should have an autocomplete-enabled search box" do
          response.should have_tag("input[type=text][class=usagov-search-autocomplete]")
        end
        
        context "when a filter value is specified" do
          before do
            SaytSuggestion.create(:phrase => 'something', :affiliate => @affiliate)
            SaytSuggestion.create(:phrase => 'thingsome', :affiliate => @affiliate)
            get :index, :affiliate_id => @affiliate.id, :filter => "some"
          end
        
          it "should assign the filter value" do
            assigns[:filter].should == "some"
          end
        
          it "should show only entries that are prefixed by the filter string" do
            response.should have_tag("td[class=sayt_suggestion]", :text => "something")
            response.should_not have_tag("td[class=sayt_suggestion]", :text => "thingsome")
          end
          
          it "should fill in the filter field with the filter value and add a 'Remove Filter' link" do
            response.should have_tag("input[name=filter][value=some]")
            response.should have_tag("a", :text => "Remove Filter")
          end
        end
      end
      
      context "when the affiliate SAYT set to global" do
        before do
          @affiliate.update_attributes(:is_sayt_enabled => true, :is_affiliate_suggestions_enabled => false)
          get :index, :affiliate_id => @affiliate.id
        end
        
        it "should not show the add, current entries and bulk upload portions of the page" do
          response.should_not have_tag("div[id=add_a_new_entry]")
          response.should_not have_tag("div[id=current_entries]")
          response.should_not have_tag("div[id=bulk_upload]")
        end
        
        it "should have an autocomplete-enabled search box" do
          response.should have_tag("input[type=text][class=usagov-search-autocomplete]")
        end
      end
        
      context "when the affiliate SAYT set to global" do
        before do
          @affiliate.update_attributes(:is_sayt_enabled => false, :is_affiliate_suggestions_enabled => false)
          get :index, :affiliate_id => @affiliate.id
        end
        
        it "should not show the add, current entries and bulk upload portions of the page" do
          response.should_not have_tag("div[id=add_a_new_entry]")
          response.should_not have_tag("div[id=current_entries]")
          response.should_not have_tag("div[id=bulk_upload]")
        end
        
        it "should have an autocomplete-enabled search box" do
          response.should have_tag("input[type=text][class=usagov-search]")
        end
      end      
    end
  end
  
  describe "#create" do
    context "when logged in as an affiliate" do
      before do
        @user = users("affiliate_manager")
        UserSession.create(@user)
        @affiliate = @user.affiliates.first
      end
      
      context "when the phrase for the given affiliate does not already exist" do
        it "should create a suggestion that's protected and very popular" do
          post :create, :affiliate_id => @affiliate.id, :sayt_suggestion => {:phrase => 'suggestion'}
          assigns[:sayt_suggestion].is_protected.should be_true
          assigns[:sayt_suggestion].popularity.should == SaytSuggestion::MAX_POPULARITY
        end
      end
      
      context "when the phrase for the given affiliate does already exist, but has been deleted" do
        before do
          @suggestion = SaytSuggestion.create(:phrase => 'existing suggestion', :affiliate => @affiliate, :is_protected => true, :deleted_at => Time.now, :popularity => 120)
        end
        
        it "should undelete the existing suggestion" do
          post :create, :affiliate_id => @affiliate.id, :sayt_suggestion => {:phrase => 'existing suggestion'}
          assigns[:sayt_suggestion].id.should == @suggestion.id
          assigns[:sayt_suggestion].deleted_at.should be_nil
          assigns[:sayt_suggestion].is_protected.should be_true
          assigns[:sayt_suggestion].popularity.should == SaytSuggestion::MAX_POPULARITY
        end
      end
    end
  end
  
  describe "#delete" do
    context "when logged in as an affiliate" do
      before do
        @user = users("affiliate_manager")
        UserSession.create(@user)
        @affiliate = @user.affiliates.first
      end
      
      context "for existing suggestion that is unprotected" do
        before do
          @suggestion = SaytSuggestion.create(:phrase => 'delete me', :affiliate => @affiliate, :is_protected => false)
        end
      
        it "should set the suggestion to deleted" do
          delete :destroy, :affiliate_id => @affiliate.id, :id => @suggestion.id
          assigns[:sayt_suggestion].deleted_at.should_not be_nil
          assigns[:sayt_suggestion].is_protected.should be_true
        end
      end
    end
  end
end