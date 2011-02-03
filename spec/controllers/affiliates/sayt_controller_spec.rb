require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Affiliates::SaytController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "#index" do
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