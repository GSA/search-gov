require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Affiliates::HomeController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "do GET on #index" do
    it "should not require affiliate login" do
      get :index
      response.should be_success
    end
  end
  
  describe "do GET on #how_it_works" do
    it "should have a title" do
      get :how_it_works
      response.should be_success
    end
  end
  
  describe "do GET on #demo" do
    it "should have a title" do
      get :demo
      response.should be_success
    end

    it "assigns @affiliate_ads that contains 3 items" do
      get :demo
      assigns[:affiliate_ads].size.should == 3
    end

    it "assigns @affiliate_ads that contains more than 3 items if all parameter is defined" do
      get :demo, :all => ""
      assigns[:affiliate_ads].size.should > 3
    end
  end

  describe "do GET on #new" do
    it "should require affiliate login for new" do
      get :new
      response.should redirect_to(login_path)
    end

    context "when logged in" do
      before do
        UserSession.create(users(:affiliate_manager_with_no_affiliates))
      end

      it "should assign @title" do
        get :new
        assigns[:title].should_not be_blank
      end

      it "should assign @user" do
        get :new
        assigns[:user].should == users(:affiliate_manager_with_no_affiliates)
      end

      it "should assign @current_step to :edit_contact_information" do
        get :new
        assigns[:current_step].should == :edit_contact_information
      end
    end
  end

  describe "do GET on #edit" do
    it "should require affiliate login for edit" do
      get :edit, :id => affiliates(:power_affiliate).id
      response.should redirect_to(login_path)
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
      end

      it "should require affiliate login for edit" do
        get :edit, :id => affiliates(:power_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate being edited" do
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should redirect to home page" do
        get :edit, :id => affiliates(:another_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as the affiliate manager" do
      integrate_views
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should assign @title" do
        get :edit, :id => affiliates(:basic_affiliate).id
        assigns[:title].should_not be_blank
      end

      it "should render the edit page" do
        get :edit, :id => affiliates(:basic_affiliate).id
        response.should render_template("edit")
      end
    end
  end

  describe "do GET on #edit_site_information" do
    it "should require affiliate login for edit_site_information" do
      get :edit_site_information, :id => affiliates(:power_affiliate).id
      response.should redirect_to(login_path)
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
      end

      it "should require affiliate login for edit_site_information" do
        get :edit_site_information, :id => affiliates(:power_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate being edited" do
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should redirect to home page" do
        get :edit_site_information, :id => affiliates(:another_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as the affiliate manager" do
      integrate_views
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should assign @title" do
        get :edit_site_information, :id => affiliates(:basic_affiliate).id
        assigns[:title].should_not be_blank
      end

      it "should render the edit_site_information page" do
        get :edit_site_information, :id => affiliates(:basic_affiliate).id
        response.should render_template("edit_site_information")
      end
    end
  end

  describe "do POST on #update_site_information" do
    before do
      @affiliate = affiliates(:power_affiliate)
    end

    it "should require affiliate login for update_site_information" do
      post :update_site_information, :id => @affiliate.id, :affiliate=> {}
      response.should redirect_to(login_path)
    end

    context "when logged in as an affiliate manager" do
      before do
        user = users(:affiliate_manager)
        UserSession.create(user)
        Affiliate.should_receive(:find).and_return(@affiliate)
      end

      it "should assign @affiliate" do
        post :update_site_information, :id => @affiliate.id, :affiliate=> {}
        assigns[:affiliate].should == @affiliate
      end

      it "should update @affiliate attributes" do
        @affiliate.should_receive(:update_attributes)
        post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}
      end

      context "when the affiliate update attributes successfully for 'Save for Preview' request" do
        before do
          @affiliate.should_receive(:update_attributes_for_staging).and_return(true)
        end

        it "should set a flash[:success] message" do
          post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}, :commit => "Save for Preview"
          flash[:success].should_not be_blank
        end

        it "should redirect to affiliate specific page" do
          post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}, :commit => "Save for Preview"
          response.should redirect_to(affiliate_path(@affiliate))
        end
      end

       context "when the affiliate failed to update attributes for 'Save for Preview' request" do
        before do
          @affiliate.should_receive(:update_attributes_for_staging).and_return(false)
        end

        it "should assign @title" do
          post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}, :commit => "Save for Preview"
          assigns[:title].should_not be_blank
        end

        it "should redirect to edit site information page" do
          post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}, :commit => "Save for Preview"
          response.should render_template(:edit_site_information)
        end
      end

      context "when the affiliate update attributes successfully for 'Make Live' request" do
        before do
          @affiliate.should_receive(:update_attributes_for_current).and_return(true)
        end

        it "should set a flash[:success] message" do
          post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}, :commit => "Make Live"
          flash[:success].should_not be_blank
        end

        it "should redirect to affiliate specific page" do
          post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}, :commit => "Make Live"
          response.should redirect_to(affiliate_path(@affiliate))
        end
      end

       context "when the affiliate failed update attributes for 'Make Live' request" do
        before do
          @affiliate.should_receive(:update_attributes_for_current).and_return(false)
        end

        it "should assign @title" do
          post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}, :commit => "Make Live"
          assigns[:title].should_not be_blank
        end

        it "should redirect to edit site information  page" do
          post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}, :commit => "Make Live"
          response.should render_template(:edit_site_information)
        end
      end

    end
  end

  describe "do POST on #update" do
    it "should require affiliate login for update" do
      post :update, :id => affiliates(:power_affiliate).id, :affiliate=> {}
      response.should redirect_to(login_path)
    end

    context "when logged in as an affiliate manager" do
      before do
        user = users(:affiliate_manager)
        UserSession.create(user)
        @affiliate = user.affiliates.first
      end

      it "should update the Affiliate" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"newname", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        @affiliate.reload
        @affiliate.name.should == "newname"
        @affiliate.footer.should == "BAR"
        @affiliate.header.should == "FOO"
        @affiliate.domains.should == "BLAT"
      end

      it "should redirect to affiliates home on success with flash message" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"newname", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        response.should redirect_to(home_affiliates_path(:said=>@affiliate.id))
        flash[:success].should_not be_nil
      end

      it "should render edit on failure" do
        post :update, :id => @affiliate.id, :affiliate=> {:name=>"", :header=>"FOO", :footer=>"BAR", :domains=>"BLAT"}
        response.should render_template(:edit)
      end
    end
  end

  describe "do POST on #update_contact_information" do
    it "should require login for update_contact_information" do
      post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
      response.should redirect_to(login_path)
    end

    context "when logged in" do
      before do
        UserSession.create(users(:affiliate_manager_with_no_affiliates))
        User.should_receive(:find_by_id).and_return(users(:affiliate_manager_with_no_affiliates))
      end

      it "should assign @title" do
        post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
        assigns[:title].should_not be_blank
      end

      it "should assign @user" do
        post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
        assigns[:user].should == users(:affiliate_manager_with_no_affiliates)
      end

      it "should set strict_mode on user to true" do
        users(:affiliate_manager_with_no_affiliates).should_receive(:strict_mode=).with(true)
        post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
      end

      it "should update_attributes on user" do
        users(:affiliate_manager_with_no_affiliates).should_receive(:update_attributes)
        post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
      end

      it "should render the new template" do
        users(:affiliate_manager_with_no_affiliates).should_receive(:update_attributes).and_return(true)
        post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
        response.should render_template("new")
      end

      context "when the user update_attributes successfully" do
        before do
          users(:affiliate_manager_with_no_affiliates).should_receive(:update_attributes).and_return(true)
        end

        it "should assign @affiliate" do
          affiliate = stub_model(Affiliate)
          Affiliate.should_receive(:new).and_return(affiliate)
          post :update_contact_information
          assigns[:affiliate].should == affiliate
        end

        it "should assign @current_step to :new_site_information" do
          post :update_contact_information
          assigns[:current_step].should == :new_site_information
        end
      end

      context "when the user fails to update_attributes" do
        it "should assign @current_step to :edit_contact_information" do
          users(:affiliate_manager_with_no_affiliates).should_receive(:update_attributes).and_return(false)
          post :update_contact_information
          assigns[:current_step].should == :edit_contact_information
        end
      end
    end
  end

  describe "do POST on #create" do
    it "should require login for create" do
      post :create
      response.should redirect_to(login_path)
    end

    context "when logged in" do
      before do
        UserSession.create(users(:affiliate_manager_with_no_affiliates))
        @affiliate = stub_model(Affiliate)
        Affiliate.should_receive(:new).and_return(@affiliate)
      end

      it "should assign @title" do
        post :create
        assigns[:title].should_not be_blank
      end

      it "should assign @affiliate" do
        post :create
        assigns[:affiliate].should == @affiliate
      end

      it "should save the affiliate" do
        @affiliate.should_receive(:save)
        post :create
      end

      context "when the affiliate saves successfully" do
        before do
          @affiliate.should_receive(:save).twice.and_return(true)
        end

        it "should assign @current_step to :get_code" do
          post :create
          assigns[:current_step].should == :get_the_code
        end

        it "should render the new template" do
          post :create
          response.should render_template("new")
        end
      end

      context "when the affiliate fails to save" do
        before do
          @affiliate.should_receive(:save).and_return(false)
        end

        it "should assign @current_step to :new_site_information" do
          post :create
          assigns[:current_step].should == :new_site_information
        end

        it "should render the new template" do
          post :create
          response.should render_template("new")
        end
      end
    end

  end
end
