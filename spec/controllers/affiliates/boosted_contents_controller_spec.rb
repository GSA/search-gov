require File.expand_path(File.dirname(__FILE__) + '/../../spec_helper')

describe Affiliates::BoostedContentsController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "do GET on #new" do
    it "should require affiliate login for new" do
      get :new, :affiliate_id => affiliates(:power_affiliate).id
      response.should redirect_to(new_user_session_path)
    end

    context "when logged in but not an affiliate manager" do
      before do
        UserSession.create(users(:affiliate_admin))
      end

      it "should require affiliate login for #new" do
        get :new, :affiliate_id => affiliates(:power_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who doesn't own the affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
      end

      it "should redirect to home page" do
        get :new, :affiliate_id => affiliates(:another_affiliate).id
        response.should redirect_to(home_page_path)
      end
    end

    context "when logged in as an affiliate manager who owns the affiliate" do
      before do
        UserSession.create(users(:affiliate_manager))
        get :new, :affiliate_id => affiliates(:power_affiliate).id
      end

      should_render_template 'affiliates/boosted_contents/new.html.haml', :layout => 'account'
    end
  end

  describe "create" do
    it "should require affiliate login" do
      post :create, :affiliate_id => affiliates(:power_affiliate).id
      response.should redirect_to(new_user_session_path)
    end

    context "logged in" do
      before :each do
        @affiliate = affiliates(:basic_affiliate)
        UserSession.create(@affiliate.owner)
      end

      it "should redirect back to new if a new site is added" do
        post :create, :affiliate_id => @affiliate.to_param, :boosted_content => {:url => "a url", :title => "a title", :description => "a description"}

        response.should redirect_to new_affiliate_boosted_content_path
        
        @affiliate.reload
        @affiliate.boosted_contents.length.should == 1
      end

      it "should render if errors" do
        existing_boosted_content = @affiliate.boosted_contents.create!(:url => "existing url", :title => "a title", :description => "a description")

        post :create, :affiliate_id => @affiliate.to_param, :boosted_content => {:url => "a url", :description => "a description"}
        response.should render_template(:new)

        @affiliate.reload
        @affiliate.boosted_contents.length.should == 1

        assigns[:boosted_content].errors[:title].should == "can't be blank"
        assigns[:boosted_contents].should == [existing_boosted_content]
      end

      it "should ?? if adding a duplicate url"

    end
  end

  describe "update" do
    before :each do
      @affiliate = affiliates(:basic_affiliate)
      @boosted_content = @affiliate.boosted_contents.create!(:url => "a url", :title => "a title", :description => "a description")
      UserSession.create(@affiliate.owner)
    end

    it "should redirect back to new on success" do
      post :update, :affiliate_id => @affiliate.to_param, :id => @boosted_content.to_param, :boosted_content => {:url => "new url", :title => "new title", :description => "new description"}

      response.should redirect_to new_affiliate_boosted_content_path

      @boosted_content.reload
      @boosted_content.url.should == "new url"
      @boosted_content.title.should == "new title"
      @boosted_content.description.should == "new description"
    end

    it "should render if errors" do
      post :update, :affiliate_id => @affiliate.to_param, :id => @boosted_content.to_param, :boosted_content => {:url => "new url", :title => "new title", :description => ""}

      response.should render_template(:edit)

      assigns[:boosted_content].errors[:description].should == "can't be blank"
    end


    it "should ?? if updating to a duplicate url"

  end

  describe "destroy" do
    it "should delete, flash, and redirect" do
      affiliate = affiliates(:basic_affiliate)
      boosted_content = affiliate.boosted_contents.create!(:url => "a url", :title => "a title", :description => "a description")
      UserSession.create(affiliate.owner)

      post :destroy, :affiliate_id => affiliate.to_param, :id => boosted_content.to_param

      response.should redirect_to new_affiliate_boosted_content_path
      affiliate.reload.boosted_contents.should be_empty
    end

  end

  describe "bulk upload" do
    before :each do
      @affiliate = affiliates(:basic_affiliate)
      UserSession.create(@affiliate.owner)
      @xml = StringIO.new("xml")
    end

    it "should process the xml file and redirect to new" do
      BoostedContent.should_receive(:process_boosted_content_xml_upload_for).with(@affiliate, @xml).and_return(true)

      post :bulk, :affiliate_id => @affiliate.to_param, :xml_file => @xml

      response.should redirect_to new_affiliate_boosted_content_path
    end

    it "should notify if errors" do
      existing_boosted_content = @affiliate.boosted_contents.create!(:url => "existing url", :title => "a title", :description => "a description")

      BoostedContent.should_receive(:process_boosted_content_xml_upload_for).with(@affiliate, @xml).and_return(false)

      post :bulk, :affiliate_id => @affiliate.to_param, :xml_file => @xml

      response.should redirect_to(new_affiliate_boosted_content_path)
      flash[:error].should =~ /could not be processed/
    end
  end

  describe "lots of bulk content" do
    before :each do
      @affiliate = affiliates(:basic_affiliate)
      UserSession.create(@affiliate.owner)
      @original_max_boosted_content = Affiliates::BoostedContentsController::MAX_DISPLAYED_BOOSTED_CONTENT
      Affiliates::BoostedContentsController::MAX_DISPLAYED_BOOSTED_CONTENT = 2
    end

    after :each do
      Affiliates::BoostedContentsController::MAX_DISPLAYED_BOOSTED_CONTENT = @original_max_boosted_content
    end

    it "should not set the bulk content variable if there are too many (show count instead)" do
      3.times { |i| @affiliate.boosted_contents.create(:title => "a title", :description => "a description", :url => "http://url#{i}.com") }

      get :new, :affiliate_id => @affiliate.to_param
      response.should be_success

      assigns(:boosted_content_count).should == 3
      assigns(:boosted_contents).should be_empty
    end

    it "should set the bulk content variable if there are too many (show count instead)" do
      boosted_content = @affiliate.boosted_contents.create(:title => "a title", :description => "a description", :url => "http://url.com")

      get :new, :affiliate_id => @affiliate.to_param
      response.should be_success

      assigns(:boosted_content_count).should == 1
      assigns(:boosted_contents).should == [boosted_content]
    end
  end

  describe "bulk delete" do
  end
end
