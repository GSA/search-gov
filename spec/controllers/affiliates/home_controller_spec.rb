require 'spec_helper'

describe Affiliates::HomeController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "do GET on #index" do
    it "should redirect to affiliate home" do
      get :index
      response.should redirect_to(home_affiliates_path)
    end
  end

  describe "#home" do
    context "when user is not logged in" do
      before do
        get :home
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:non_affiliate_admin))
        get :home
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate admin" do
      before do
        UserSession.create(users(:affiliate_admin))
        get :home
      end

      it { should respond_with(:success) }
    end

    context "when logged in as an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :home
      end

      it { should respond_with(:success) }
    end
  end

  describe "do GET on #new" do
    it "should require affiliate login for new" do
      get :new
      response.should redirect_to(login_path)
    end

    context "when logged in with approved user" do
      before do
        UserSession.create(users(:affiliate_manager_with_no_affiliates))
        get :new
      end

      it "should assign @title" do
        assigns[:title].should_not be_blank
      end

      it "should assign @current_step to :basic_settings" do
        assigns[:current_step].should == :basic_settings
      end

      it "should assign a new affiliate" do
        assigns[:affiliate].should_not be_nil
      end
    end

    context "when logged in with pending approval user" do
      before do
        UserSession.create(users(:affiliate_manager_with_pending_approval_status))
      end

      it "should redirect to affiliates home page" do
        get :new
        response.should redirect_to(home_affiliates_path)
      end

      it "should set flash[:notice] message" do
        get :new
        flash[:notice].should_not be_blank
      end
    end
  end

  describe "do POST on #create" do
    it "should require login for create" do
      post :create
      response.should redirect_to(login_path)
    end

    context "when logged in" do
      let(:current_user) { users(:affiliate_manager_with_no_affiliates) }

      before { UserSession.create(current_user) }

      it "should assign @affiliate" do
        post :create, :affiliate => {:display_name => 'new_affiliate'}
        assigns[:affiliate].should_not be_nil
      end

      it "should save the affiliate" do
        post :create, :affiliate => {:display_name => 'new_affiliate'}
        assigns[:affiliate].id.should_not be_nil
      end

      context "when the affiliate saves successfully" do
        let(:affiliate) { mock_model(Affiliate, :users => []) }
        let(:emailer) { mock(Emailer, :deliver => true) }

        before do
          Affiliate.should_receive(:new).with(hash_excluding(:name)).and_return(affiliate)
          affiliate.should_receive(:name=).with('newaff')
          affiliate.should_receive(:save).and_return(true)
          affiliate.should_receive(:push_staged_changes)
          Emailer.should_receive(:new_affiliate_site).and_return(emailer)
          post :create, :affiliate => { :display_name => 'new_affiliate', :name => 'newaff' }
        end

        it { should redirect_to(content_sources_affiliate_path(affiliate))}

        it 'should add current user as the affiliate user' do
          affiliate.users.should include(current_user)
        end
      end

      context "when the affiliate fails to save" do
        let(:affiliate) { mock_model(Affiliate, :users => []) }

        before do
          Affiliate.should_receive(:new).with(hash_excluding(:name)).and_return(affiliate)
          affiliate.should_receive(:name=).with('newaff')
          affiliate.should_receive(:save).and_return(false)
          Emailer.should_not_receive(:new_affiliate_site)
          post :create, :affiliate => { :display_name => 'new_affiliate', :name => 'newaff' }
        end

        it { should assign_to(:current_step).with(:basic_settings) }
        it { should render_template(:new) }
      end
    end
  end

  describe "do GET on content_sources" do
    before do
      @user = users(:affiliate_manager_with_no_affiliates)
      @user.affiliates << Affiliate.new({:name => 'new_aff', :display_name => 'new_aff', :theme => 'default', :locale => 'en'}, :as => :test)
      @user.affiliates.first.id.should_not be_nil
    end

    it "should require login" do
      get :content_sources, :id => @user.affiliates.first.id
      response.should redirect_to(login_path)
    end

    context "when logged in" do
      before do
        UserSession.create(@user)
        get :content_sources, :id => @user.affiliates.first.id
      end

      it "should assign @title" do
        assigns[:title].should_not be_blank
      end

      it "should assing the current step to 'content_sources'" do
        assigns[:current_step].should == :content_sources
      end

      it "should render the content sources page" do
        response.should render_template("content_sources")
      end
    end
  end

  describe "do PUT on create_content_sources" do
    let(:current_user) { users(:affiliate_manager_with_no_affiliates) }
    let(:affiliate) { Affiliate.create!({ name: 'new_aff', display_name: 'new_aff', theme: 'default', locale: 'en' }) }

    before { current_user.affiliates << affiliate }

    it "should require login" do
      put :create_content_sources, :id => current_user.affiliates.first.id
      response.should redirect_to(login_path)
    end

    context "when logged in" do
      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
      end

      context 'when the affiliate updates successfully' do
        before do
          affiliate_params = mock('request params', to_s: 'create content source params')
          affiliate.should_receive(:update_attributes).with('create content source params').and_return(true)
          affiliate.should_receive(:autodiscover)
          put :create_content_sources, id: affiliate.id, affiliate: affiliate_params
        end

        it { should assign_to(:affiliate).with(affiliate) }
        it { should redirect_to get_the_code_affiliate_path(affiliate) }
      end

      context 'when the affiliate fails to update' do
        before do
          affiliate_params = mock('request params', to_s: 'create content source params')
          affiliate.should_receive(:update_attributes).with('create content source params').and_return(false)
          affiliate.should_not_receive(:autodiscover)
          put :create_content_sources, id: affiliate.id, affiliate: affiliate_params
        end

        it { should assign_to(:affiliate).with(affiliate) }
        it { should assign_to(:current_step).with(:content_sources) }
        it { should render_template(:content_sources) }
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
      before do
        current_user = users(:affiliate_manager)
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        @affiliate = affiliates(:basic_affiliate)
        current_user.stub_chain(:affiliates, :find).and_return(@affiliate)
      end

      it "should assign @title" do
        get :edit_site_information, :id => @affiliate.id
        assigns[:title].should_not be_blank
      end

      it "should assign @affiliate" do
        get :edit_site_information, :id => @affiliate.id
        assigns[:affiliate].should == @affiliate
      end

      it "should not sync staged attributes on @affiliate" do
        @affiliate.should_not_receive(:sync_staged_attributes)
        get :edit_site_information, :id => @affiliate.id
      end

      it "should render the edit_site_information page" do
        get :edit_site_information, :id => @affiliate.id
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
      end

      it "should assign @affiliate and update @affiliate attributes" do
        post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}
        assigns[:affiliate].should == @affiliate
        assigns[:affiliate].display_name.should == "new display name"
      end

      context "when the affiliate update attributes successfully for 'Save for Preview' request" do
        before do
          post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}, :commit => "Save for Preview"
        end

        it "should upate the affiliate's staged fields" do
          assigns[:affiliate].has_staged_content.should == true
          assigns[:affiliate].display_name.should == "new display name"
        end

        it "should set a flash[:success] message" do
          flash[:success].should_not be_blank
        end

        it "should redirect to affiliate specific page" do
          response.should redirect_to(affiliate_path(@affiliate))
        end
      end

      context "when the affiliate failed to update attributes for 'Save for Preview' request" do
        before do
         post :update_site_information, :id => @affiliate.id, :affiliate=> { :display_name => nil }, :commit => "Save for Preview"
        end

        it "should assign @title" do
         assigns[:title].should_not be_blank
        end

        it "should redirect to edit site information page" do
         response.should render_template(:edit_site_information)
        end
      end

      context "when the affiliate updates attributes successfully for 'Make Live' request" do
        it "should not send an email, set a flash[:success] message and redirect to affiliate specific page" do
          Emailer.should_not_receive(:affiliate_header_footer_change)
          post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}, :commit => "Make Live"
          flash[:success].should_not be_blank
          response.should redirect_to(affiliate_path(@affiliate))
        end
      end

      context "when the affiliate updates the header and footer" do
        before do
          @emailer = mock(Emailer)
          @emailer.stub!(:deliver).and_return true
        end

        it "should send an email to the affiliate's users notifying them of the update" do
          Emailer.should_receive(:affiliate_header_footer_change).with(@affiliate).and_return @emailer
          post :update_site_information, :id => @affiliate.id, :affiliate => { :header => 'New Header', :footer => 'New Footer' }, :commit => 'Make Live'
        end
      end

      context "when the affiliate failed update attributes for 'Make Live' request" do
        before do
          post :update_site_information, :id => @affiliate.id, :affiliate=> {:display_name => nil}, :commit => "Make Live"
        end

        it "should assign @title" do
          assigns[:title].should_not be_blank
        end

        it "should redirect to edit site information  page" do
          response.should render_template(:edit_site_information)
        end
      end
    end
  end

  describe "do GET on #edit_look_and_feel" do
    it "should require affiliate login for edit_look_and_feel" do
      get :edit_look_and_feel, :id => affiliates(:power_affiliate).id
      response.should redirect_to(login_path)
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
      end

      it "should require affiliate login for edit_look_and_feel" do
        get :edit_look_and_feel, :id => affiliates(:power_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate being edited" do
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should redirect to home page" do
        get :edit_look_and_feel, :id => affiliates(:another_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as the affiliate manager" do
      before do
        UserSession.create(users(:affiliate_manager))
        @affiliate = affiliates(:basic_affiliate)
        get :edit_look_and_feel, :id => affiliates(:basic_affiliate).id
      end

      it "should assign @affiliate" do
        assigns[:affiliate].should == @affiliate
      end

      it "should assign @title" do
        assigns[:title].should_not be_blank
      end

      it "should sync staged attributes on @affiliate" do
        get :edit_look_and_feel, :id => affiliates(:basic_affiliate).id
        assigns[:affiliate].staged_header.should == assigns[:affiliate].header
        assigns[:affiliate].staged_footer.should == assigns[:affiliate].footer
        assigns[:affiliate].staged_search_results_page_title.should == assigns[:affiliate].search_results_page_title
        assigns[:affiliate].has_staged_content.should == false
      end

      it "should render the edit_look_and_feel page" do
        response.should render_template("edit_look_and_feel")
      end
    end
  end

  describe "do POST on #update_look_and_feel" do
    before do
      @affiliate = affiliates(:power_affiliate)
    end

    it "should require affiliate login for update_look_and_feel" do
      post :update_look_and_feel, :id => @affiliate.id, :affiliate=> {}
      response.should redirect_to(login_path)
    end

    context "when logged in as an affiliate manager" do
      before do
        user = users(:affiliate_manager)
        UserSession.create(user)
      end

      context "when posting" do
        before do
          post :update_look_and_feel, :id => @affiliate.id, :affiliate=> {}
        end

        it "should assign @affiliate" do
          assigns[:affiliate].should == @affiliate
        end
      end

      context "when the affiliate update attributes successfully for 'Save for Preview' request" do
        before do
          post :update_look_and_feel, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}, :commit => "Save for Preview"
        end

        it "should set a flash[:success] message" do
          flash[:success].should_not be_blank
        end

        it "should redirect to affiliate specific page" do
          response.should redirect_to(affiliate_path(@affiliate))
        end
      end

     context "when the affiliate failed to update attributes for 'Save for Preview' request" do
       before do
         post :update_look_and_feel, :id => @affiliate.id, :affiliate=> {:display_name => nil}, :commit => "Save for Preview"
       end

       it "should assign @title" do
         assigns[:title].should_not be_blank
       end

       it "should redirect to edit site information page" do
         response.should render_template(:edit_look_and_feel)
       end
     end

      context "when the affiliate update attributes successfully for 'Make Live' request" do
        before do
          post :update_look_and_feel, :id => @affiliate.id, :affiliate=> {:display_name => "new display name"}, :commit => "Make Live"
        end

        it "should set a flash[:success] message" do
          flash[:success].should_not be_blank
        end

        it "should redirect to affiliate specific page" do
          response.should redirect_to(affiliate_path(@affiliate))
        end
      end

       context "when the affiliate failed update attributes for 'Make Live' request" do
        before do
          post :update_look_and_feel, :id => @affiliate.id, :affiliate=> {:display_name => nil}, :commit => "Make Live"
        end

        it "should assign @title" do
          assigns[:title].should_not be_blank
        end

        it "should redirect to edit site information  page" do
          response.should render_template(:edit_look_and_feel)
        end
      end

    end
  end

  describe "do GET on #edit_header_footer" do
    context "when user is not logged in" do
      before do
        get :edit_header_footer, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
        get :edit_header_footer, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate being edited" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :edit_header_footer, :id => affiliates(:another_affiliate).id
      end

      it { should redirect_to(home_page_path) }
    end

    context "when logged in as the affiliate manager" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:sync_staged_attributes)

        get :edit_header_footer, :id => affiliate.id
      end

      it { should assign_to(:affiliate).with(affiliate) }
      specify { affiliate.staged_managed_header_links.should_not be_empty }
      specify { affiliate.staged_managed_footer_links.should_not be_empty }
    end
  end

  describe "do PUT on #update_header_footer" do
    context "when user is not logged in" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      before do
        put :update_header_footer, :id => affiliate.id, :affiliate=> {}
      end

      it { should redirect_to(login_path) }
    end

    context "when logged in as an affiliate manager and successfully save for preview" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:update_attributes_for_staging).and_return(true)
        put :update_header_footer, :id => affiliate.id, :affiliate=> {:header => "staged header"}, :commit => "Save for Preview"
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should set_the_flash.to(/Staged changes to your site successfully/) }
      it { should redirect_to(affiliate_path(affiliate)) }
    end

    context "when logged in as an affiliate manager and failed to save for preview" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:update_attributes_for_staging).and_return(false)
        put :update_header_footer, :id => affiliate.id, :affiliate=> {:staged_header => "staged header"}, :commit => "Save for Preview"
      end

      it { should assign_to(:affiliate).with(affiliate) }
      specify { affiliate.staged_managed_header_links.should_not be_empty }
      specify { affiliate.staged_managed_footer_links.should_not be_empty }
      it { should render_template(:edit_header_footer) }
    end

    context "when logged in as an affiliate manager and successfully Make Live" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:update_attributes_for_live).and_return(true)
        put :update_header_footer, :id => affiliate.id, :affiliate=> {:staged_header => "staged header"}, :commit => "Make Live"
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should set_the_flash.to(/Updated changes to your live site successfully/) }
      it { should redirect_to(affiliate_path(affiliate)) }
    end

    context "when logged in as an affiliate manager and failed to Make Live" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_receive(:update_attributes_for_live).and_return(false)
        put :update_header_footer, :id => affiliate.id, :affiliate=> {:staged_header => "staged header"}, :commit => "Make Live"
      end

      it { should assign_to(:affiliate).with(affiliate) }
      specify { affiliate.staged_managed_header_links.should_not be_empty }
      specify { affiliate.staged_managed_footer_links.should_not be_empty }
      it { should render_template(:edit_header_footer) }
    end
  end

  describe "do POST on #update_contact_information" do
    it "should require login for update_contact_information" do
      post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
      response.should redirect_to(login_path)
    end

    context "when logged in with approved user" do
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

    context "when logged in with pending contact information user" do
      before do
        UserSession.create(users(:affiliate_manager_with_pending_contact_information_status))
        User.should_receive(:find_by_id).and_return(users(:affiliate_manager_with_pending_contact_information_status))
      end

      it "assigns @user" do
        post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
        assigns[:user].should == users(:affiliate_manager_with_pending_contact_information_status)
      end

      it "sets @user.strict_mode to true" do
        users(:affiliate_manager_with_pending_contact_information_status).should_receive(:strict_mode=).with(true)
        post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
      end

      it "updates the User attributes" do
        users(:affiliate_manager_with_pending_contact_information_status).should_receive(:update_attributes)
        post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
      end

      context "when the user update attributes successfully" do
        before do
          users(:affiliate_manager_with_pending_contact_information_status).should_receive(:update_attributes).and_return(true)
        end

        it "assigns flash[:success]" do
          post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
          flash[:success].should_not be_blank
        end

        it "redirects to affiliates landing page" do
          post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
          response.should redirect_to(home_affiliates_path)
        end
      end

      context "when the user fails to update_attributes" do
        before do
          users(:affiliate_manager_with_pending_contact_information_status).should_receive(:update_attributes).and_return(false)
          post :update_contact_information, :user => {:email => "changed@foo.com", :contact_name => "BAR"}
        end

        it "renders the affiliates home page" do
          response.should render_template("home")
        end
      end
    end
  end

  describe "do POST on #push_content_for" do
    before do
      @affiliate = affiliates(:power_affiliate)
      @affiliate.update_attributes(:has_staged_content => true)
    end

    context "when not logged in" do
      before do
        post :push_content_for, :id => @affiliate.id
      end

      it "should require affiliate login for push_content_for" do
        response.should redirect_to(login_path)
      end
    end

    context "when logged in as an affiliate manager and successfully push changes with header or footer changes" do
      before do
        user = users(:affiliate_manager)
        UserSession.create(user)
        User.should_receive(:find_by_id).and_return(user)
        user.stub_chain(:affiliates, :find).and_return(@affiliate)
        @affiliate.should_receive(:push_staged_changes)
        @affiliate.should_receive(:has_changed_header_or_footer).and_return(true)
        emailer = mock('emailer')
        Emailer.should_receive(:affiliate_header_footer_change).with(@affiliate).and_return(emailer)
        emailer.should_receive(:deliver)

        post :push_content_for, :id => @affiliate.id
      end

      it { should assign_to(:affiliate).with(@affiliate) }
      it { should redirect_to(affiliate_path(@affiliate)) }
    end

    context "when logged in as an affiliate manager and successfully push changes without header or footer changes" do
      before do
        user = users(:affiliate_manager)
        UserSession.create(user)
        User.should_receive(:find_by_id).and_return(user)
        user.stub_chain(:affiliates, :find).and_return(@affiliate)
        @affiliate.should_receive(:push_staged_changes)
        @affiliate.should_receive(:has_changed_header_or_footer).and_return(false)
        Emailer.should_not_receive(:affiliate_header_footer_change)

        post :push_content_for, :id => @affiliate.id
      end

      it { should assign_to(:affiliate).with(@affiliate) }
      it { should redirect_to(affiliate_path(@affiliate)) }
    end
  end

  describe "do POST on #cancel_staged_changes_for" do
    before do
      @affiliate = affiliates(:power_affiliate)
    end

    context "when not logged in" do
      before do
        post :cancel_staged_changes_for, :id => @affiliate.id
      end

      it "should require affiliate login for cancel_staged_changes_for" do
        response.should redirect_to(login_path)
      end
    end

    context "when logged in as an affiliate manager" do
      before do
        current_user = users(:affiliate_manager)
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(@affiliate)
        @affiliate.should_receive(:cancel_staged_changes)
        post :cancel_staged_changes_for, :id => @affiliate.id
      end

      it { should assign_to(:affiliate).with(@affiliate) }
      it { should redirect_to(affiliate_path(@affiliate)) }
    end
  end

  describe "do GET on #preview" do
    it "should require affiliate login for preview" do
      get :preview, :id => affiliates(:power_affiliate).id
      response.should redirect_to(login_path)
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
      end

      it "should require affiliate login for preview" do
        get :preview, :id => affiliates(:power_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate being previewed" do
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should redirect to home page" do
        get :preview, :id => affiliates(:another_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as the affiliate manager" do
      render_views
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should assign @title" do
        get :preview, :id => affiliates(:basic_affiliate).id
        assigns[:title].should_not be_blank
      end

      it "should render the preview page" do
        get :preview, :id => affiliates(:basic_affiliate).id
        response.should render_template("preview")
      end
    end
  end

  describe "do GET on #best_bets" do
    context "when not logged in" do
      before do
        get :best_bets, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to login_path }
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
        get :best_bets, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate being previewed" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :best_bets, :id => affiliates(:another_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as the affiliate manager" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:boosted_contents) { mock('Boosted Contents') }
      let(:recent_boosted_contents) { mock('recent Boosted Contents') }
      let(:featured_collections) { mock('Featured Collections') }
      let(:recent_featured_collections) { mock('recent Featured Collections') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)

        affiliate.should_receive(:boosted_contents).and_return(boosted_contents)
        boosted_contents.should_receive(:recent).and_return(recent_boosted_contents)

        affiliate.should_receive(:featured_collections).and_return(featured_collections)
        featured_collections.should_receive(:recent).and_return(recent_featured_collections)

        get :best_bets, :id => affiliates(:basic_affiliate).id
      end

      it { should assign_to :title }
      it { should assign_to(:boosted_contents).with(recent_boosted_contents) }
      it { should assign_to(:featured_collections).with(recent_featured_collections) }
      it { should respond_with(:success) }
    end
  end

  describe "do GET on #urls_and_sitemaps" do
    context "when not logged in" do
      before do
        get :urls_and_sitemaps, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to login_path }
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:developer))
        get :urls_and_sitemaps, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate being previewed" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :urls_and_sitemaps, :id => affiliates(:another_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as the USA admin" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_admin) }
      let(:recent_sitemaps) { mock('recent sitemaps') }
      let(:recent_uncrawled_urls) { mock('recent uncrawled urls') }
      let(:recent_crawled_urls) { mock('recent crawled urls') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        affiliate.stub_chain(:sitemaps, :paginate).and_return(recent_sitemaps)
        Affiliate.should_receive(:find).and_return(affiliate)
        IndexedDocument.should_receive(:uncrawled_urls).with(affiliate, 1, 5).and_return(recent_uncrawled_urls)
        IndexedDocument.should_receive(:crawled_urls).with(affiliate, 1, 5).and_return(recent_crawled_urls)

        get :urls_and_sitemaps, :id => affiliate.id
      end

      it { should assign_to :title }
      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:sitemaps).with(recent_sitemaps) }
      it { should assign_to(:uncrawled_urls).with(recent_uncrawled_urls) }
      it { should assign_to(:crawled_urls).with(recent_crawled_urls) }
      it { should respond_with(:success) }
    end

    context "when logged in as the affiliate manager" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:recent_sitemaps) { mock('recent sitemaps') }
      let(:recent_uncrawled_urls) { mock('recent uncrawled urls') }
      let(:recent_crawled_urls) { mock('recent crawled urls') }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)

        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.stub_chain(:sitemaps, :paginate).and_return(recent_sitemaps)
        IndexedDocument.should_receive(:uncrawled_urls).with(affiliate, 1, 5).and_return(recent_uncrawled_urls)
        IndexedDocument.should_receive(:crawled_urls).with(affiliate, 1, 5).and_return(recent_crawled_urls)

        get :urls_and_sitemaps, :id => affiliate.id
      end

      it { should assign_to :title }
      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:sitemaps).with(recent_sitemaps) }
      it { should assign_to(:uncrawled_urls).with(recent_uncrawled_urls) }
      it { should assign_to(:crawled_urls).with(recent_crawled_urls) }
      it { should respond_with(:success) }
    end
  end

  describe "do GET on #edit_sidebar" do
    context "when not logged in" do
      before do
        get :edit_sidebar, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to login_path }
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
        get :edit_sidebar, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :edit_sidebar, :id => affiliates(:another_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as the affiliate manager" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        get :edit_sidebar, :id => affiliate.id
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should respond_with(:success) }
    end
  end

  describe "do PUT on #update_sidebar" do
    context "when not logged in" do
      before do
        put :update_sidebar, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to login_path }
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
        put :update_sidebar, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
        put :update_sidebar, :id => affiliates(:another_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as the affiliate manager and successfully updated the site" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_not_receive(:update_attributes_for_live)
        affiliate.should_not_receive(:update_attributes_for_staging)
        affiliate.should_receive(:update_attributes).with(hash_including(:default_search_label => 'Web')).and_return(true)

        put :update_sidebar, :id => affiliate.id, :affiliate => { :default_search_label => 'Web' }, :commit => 'Save'
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should set_the_flash.to(/Site was successfully updated/) }
      it { should redirect_to(affiliate_path(affiliate)) }
    end

    context "when logged in as the affiliate manager and failed to update the site" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_not_receive(:update_attributes_for_live)
        affiliate.should_not_receive(:update_attributes_for_staging)
        affiliate.should_receive(:update_attributes).with(hash_including(:default_search_label => 'Web')).and_return(false)

        put :update_sidebar, :id => affiliate.id, :affiliate => { :default_search_label => 'Web' }, :commit => 'Save'
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should render_template("affiliates/home/edit_sidebar") }
    end
  end

  describe "do GET on #edit_results_modules" do
    context "when not logged in" do
      before do
        get :edit_results_modules, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to login_path }
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
        get :edit_results_modules, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :edit_results_modules, :id => affiliates(:another_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as the affiliate manager" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        UserSession.create(current_user)
        get :edit_results_modules, :id => affiliate.id
      end

      it { should assign_to(:affiliate).with(affiliate) }

      it { should respond_with(:success) }
    end
  end

  describe "do PUT on #update_results_modules" do
    context "when not logged in" do
      before do
        put :update_results_modules, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to login_path }
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
        put :update_results_modules, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
        put :update_results_modules, :id => affiliates(:another_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as the affiliate manager and successfully updated the site" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_not_receive(:update_attributes_for_live)
        affiliate.should_not_receive(:update_attributes_for_staging)
        affiliate.should_receive(:update_attributes).with(hash_including(:default_search_label => 'Web')).and_return(true)

        put :update_results_modules, :id => affiliate.id, :affiliate => { :default_search_label => 'Web' }, :commit => 'Save'
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should set_the_flash.to(/Site was successfully updated/) }
      it { should redirect_to(affiliate_path(affiliate)) }
    end

    context "when logged in as the affiliate manager and failed to update the site" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        affiliate.should_not_receive(:update_attributes_for_live)
        affiliate.should_not_receive(:update_attributes_for_staging)
        affiliate.should_receive(:update_attributes).with(hash_including(:default_search_label => 'Web')).and_return(false)

        put :update_results_modules, :id => affiliate.id, :affiliate => { :default_search_label => 'Web' }, :commit => 'Save'
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should render_template("affiliates/home/edit_results_modules") }
    end
  end

  describe "do GET on #edit_external_tracking" do
    context "when not logged in" do
      before do
        get :edit_external_tracking, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to login_path }
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
        get :edit_external_tracking, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :edit_external_tracking, :id => affiliates(:another_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as the affiliate manager" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        get :edit_external_tracking, :id => affiliate.id
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should respond_with(:success) }
    end
  end

  describe "do PUT on #update_external_tracking" do
    context "when not logged in" do
      before do
        put :update_external_tracking, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to login_path }
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
        put :update_external_tracking, :id => affiliates(:power_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as an affiliate manager who doesn't belong to the affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
        put :update_external_tracking, :id => affiliates(:another_affiliate).id
      end

      it { should redirect_to home_page_path }
    end

    context "when logged in as the affiliate manager and successfully submit the request" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }
      let(:emailer) { mock(Emailer) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        external_tracking_code = '<script>var analytics;</script>'
        Emailer.should_receive(:update_external_tracking_code).with(affiliate, current_user, external_tracking_code).and_return(emailer)
        emailer.should_receive(:deliver)

        put :update_external_tracking, :id => affiliate.id, :external_tracking_code => external_tracking_code, :commit => 'Submit'
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should set_the_flash.to(/Your request to update your web analytics code has been submitted/) }
      it { should redirect_to(affiliate_path(affiliate)) }
    end

    context "when logged in as the affiliate manager and the external_tracking_code is blank" do
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:current_user) { users(:affiliate_manager) }

      before do
        UserSession.create(current_user)
        User.should_receive(:find_by_id).and_return(current_user)
        current_user.stub_chain(:affiliates, :find).and_return(affiliate)
        Emailer.should_not_receive(:update_external_tracking_code)

        put :update_external_tracking, :id => affiliate.id, :external_tracking_code => '', :commit => 'Submit'
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should set_the_flash.now.to(/Web analytics JavaScript code can't be blank/) }
      it { should render_template("affiliates/home/edit_external_tracking") }
    end
  end

  describe "do GET on #new_connection_fields" do
    render_views
    context "when logged in as the affiliate manager" do
      let(:current_user) { users(:affiliate_manager) }
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        UserSession.create(current_user)
        get :new_connection_fields, :id => affiliate.id, :format => :js
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should respond_with(:success) }
    end
  end
end
