require 'spec/spec_helper'

describe Affiliates::SaytController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "#index" do
    render_views
    context "when logged in as an affiliate" do
      before do
        @user = users("affiliate_manager")
        UserSession.create(@user)
        @affiliate = @user.affiliates[0]
        @other_affiliate = @user.affiliates[1]
      end

      it "should set the title" do
        get :index, :affiliate_id => @affiliate.id
        assigns[:title].should == 'Type-ahead Search - '
      end

      context "when the affiliate has SAYT enabled" do
        before do
          @affiliate.update_attributes(:is_sayt_enabled => true)
          get :index, :affiliate_id => @affiliate.id
        end

        it "should define a SAYT url" do
          response.should contain "var usagov_sayt_url = \"http://test.host/sayt?aid=#{@affiliate.id}&\";"
        end

        it "should show the add, current entries and bulk upload portions of the page" do
          response.should have_selector("div[id=add_a_new_entry]")
          response.should have_selector("div[id=current_entries]")
          response.should have_selector("div[id=bulk_upload]")
        end

        it "should have an autocomplete-enabled search box" do
          response.should have_selector("input[type=text][class=usagov-search-autocomplete]")
        end

        context "when we have suggestions for several different affiliates" do
          before do
            SaytSuggestion.create(:phrase => 'something', :affiliate => @affiliate)
            SaytSuggestion.create(:phrase => 'thingsome', :affiliate => @affiliate)
            SaytSuggestion.create(:phrase => 'someother', :affiliate => @other_affiliate)

          end

          context "when a filter value is specified" do
            before do
              get :index, :affiliate_id => @affiliate.id, :filter => "some"
            end

            it "should assign the filter value" do
             assigns[:filter].should == "some"
            end

            it "should show only entries that are prefixed by the filter string and belong to this affiliate" do
             response.should have_selector("td[class=sayt_suggestion]", :content => "something")
             response.should_not have_selector("td[class=sayt_suggestion]", :content => "thingsome")
             response.should_not have_selector("td[class=sayt_suggestion]", :content => "someother")
            end

            it "should fill in the filter field with the filter value and add a 'Remove Filter' link" do
              response.should have_selector("input[name=filter][value=some]")
              response.should have_selector("a", :content => "Remove Filter")
            end
          end

          context "when no filter value is specified" do
            before do
              get :index, :affiliate_id => @affiliate.id
            end

            it "should show only entries that are prefixed by the filter string and belong to this affiliate" do
              response.should have_selector("td[class=sayt_suggestion]", :content => "something")
              response.should have_selector("td[class=sayt_suggestion]", :content => "thingsome")
              response.should_not have_selector("td[class=sayt_suggestion]", :content => "someother")
            end

          end
        end
      end

      context "when the affiliate has SAYT disabled" do
        before do
          @affiliate.update_attributes(:is_sayt_enabled => false)
          get :index, :affiliate_id => @affiliate.id
        end

        it "should not show the add, current entries and bulk upload portions of the page" do
          response.should_not have_selector("div[id=add_a_new_entry]")
          response.should_not have_selector("div[id=current_entries]")
          response.should_not have_selector("div[id=bulk_upload]")
        end

        it "should not have an autocomplete-enabled search box" do
          response.should_not have_selector("input[type=text][class=usagov-search-autocomplete]")
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

  describe "#demo" do
    before do
      @affiliate = affiliates(:basic_affiliate)
      Affiliate.should_receive(:find_by_id).and_return(@affiliate)
      get :demo, :affiliate_id => @affiliate.id
    end

    it "assigns affiliate" do
      assigns[:affiliate].should == @affiliate
    end
  end

  describe "#sayt_preferences" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:current_user) { users(:affiliate_manager) }

    context "when is_sayt_enabled is = '1'" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:update_attribute).with(:is_sayt_enabled, true)
        post :preferences, :affiliate_id => affiliate.id, :is_sayt_enabled => '1'
      end

      it { should redirect_to affiliate_type_ahead_search_index_path(affiliate) }
    end

    context "when is_sayt_enabled is not set" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:update_attribute).with(:is_sayt_enabled, false)
        post :preferences, :affiliate_id => affiliate.id
      end

      it { should redirect_to affiliate_type_ahead_search_index_path(affiliate) }
      it { should set_the_flash }
    end
  end

  describe "#delete_all" do
    context "when affiliate manager is not logged in" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        delete :destroy_all, :affiliate_id => affiliate.id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:another_affiliate) { affiliates(:another_affiliate) }

      before do
        UserSession.create(users(:affiliate_manager))
        delete :destroy_all, :affiliate_id => another_affiliate.id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who belongs to the affiliate being requested" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:sayt_suggestions) { mock('SAYT suggestions') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:sayt_suggestions).and_return(sayt_suggestions)
        sayt_suggestions.should_receive(:destroy_all)

        delete :destroy_all, :affiliate_id => affiliate.id
      end

      it { should set_the_flash }
      it { should redirect_to(affiliate_type_ahead_search_index_path(affiliate)) }
    end
  end
end