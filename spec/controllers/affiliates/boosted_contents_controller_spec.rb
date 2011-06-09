require 'spec/spec_helper'

describe Affiliates::BoostedContentsController do
  fixtures :users, :affiliates
  before do
    activate_authlogic
  end

  describe "do GET on #new" do
    it "should require affiliate login for new" do
      get :new, :affiliate_id => affiliates(:power_affiliate).id
      response.should redirect_to(login_path)
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
        response.should render_template 'affiliates/boosted_contents/new', :layout => 'account'
      end
    end
  end

  describe "create" do
    it "should require affiliate login" do
      post :create, :affiliate_id => affiliates(:power_affiliate).id
      response.should redirect_to(login_path)
    end

    context "logged in" do
      before :each do
        @affiliate = affiliates(:basic_affiliate)
        UserSession.create(@affiliate.users.first)
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

        assigns[:boosted_content].errors[:title].first.should == "can't be blank"
        assigns[:boosted_contents].should == [existing_boosted_content]
      end

      it "should render new and flash an error if adding a duplicate url" do
        @affiliate.boosted_contents.create!(:url => "existing url", :title => "a title", :description => "a description")

        post :create, :affiliate_id => @affiliate.to_param, :boosted_content => {:url => "existing url", :title => "new title", :description => "a description"}

        response.should render_template(:new)

        assigns[:boosted_content].errors[:url].first.should == "has already been boosted"
        flash[:error].should =~ /problem/
      end

    end
  end

  describe "update" do
    before :each do
      @affiliate = affiliates(:basic_affiliate)
      @boosted_content = @affiliate.boosted_contents.create!(:url => "a url", :title => "a title", :description => "a description", :keywords => 'one, two, three')
      UserSession.create(@affiliate.users.first)
    end

    it "should redirect back to new on success" do
      post :update, :affiliate_id => @affiliate.to_param, :id => @boosted_content.to_param, :boosted_content => {:url => "new url", :title => "new title", :description => "new description", :keywords => 'four, five, six'}
      response.should redirect_to new_affiliate_boosted_content_path
      @boosted_content.reload
      @boosted_content.url.should == "new url"
      @boosted_content.title.should == "new title"
      @boosted_content.description.should == "new description"
      @boosted_content.keywords.should == "four, five, six"
    end

    it "should render if errors" do
      post :update, :affiliate_id => @affiliate.to_param, :id => @boosted_content.to_param, :boosted_content => {:url => "new url", :title => "new title", :description => ""}

      response.should render_template(:edit)

      assigns[:boosted_content].errors[:description].first.should == "can't be blank"
    end


    it "should alert error and render edit if updating to a duplicate url" do
      @affiliate.boosted_contents.create!(:url => "existing url", :title => "a title", :description => "a description")

      post :update, :affiliate_id => @affiliate.to_param, :id => @boosted_content.to_param, :boosted_content => {:url => "existing url", :title => "new title", :description => "a description"}

      response.should render_template(:edit)

      assigns[:boosted_content].errors[:url].first.should == "has already been boosted"
      flash[:error].should =~ /problem/
    end

  end

  describe "destroy" do
    it "should delete, flash, and redirect" do
      affiliate = affiliates(:basic_affiliate)
      boosted_content = affiliate.boosted_contents.create!(:url => "a url", :title => "a title", :description => "a description")
      UserSession.create(affiliate.users.first)

      post :destroy, :affiliate_id => affiliate.to_param, :id => boosted_content.to_param

      response.should redirect_to new_affiliate_boosted_content_path
      affiliate.reload.boosted_contents.should be_empty
    end

  end

  describe "bulk upload" do
    before :each do
      @affiliate = affiliates(:basic_affiliate)
      UserSession.create(@affiliate.users.first)
      @xml = StringIO.new("xml")
    end

    it "should process the xml file and redirect to new" do
      BoostedContent.should_receive(:process_boosted_content_xml_upload_for).with(@affiliate, @xml).and_return({:created => 4, :updated => 2})

      post :bulk, :affiliate_id => @affiliate.to_param, :xml_file => @xml

      response.should redirect_to new_affiliate_boosted_content_path

      flash[:success].should =~ /4 Boosted Content entries successfully created/
      flash[:success].should =~ /2 Boosted Content entries successfully updated/
    end

    it "should send html_safe on flash[:success]" do
      BoostedContent.should_receive(:process_boosted_content_xml_upload_for).with(@affiliate, @xml).and_return({:created => 4, :updated => 2})
      post :bulk, :affiliate_id => @affiliate.to_param, :xml_file => @xml
      response.should redirect_to new_affiliate_boosted_content_path
      flash[:success].should be_html_safe
    end

    it "should notify if errors" do
      @affiliate.boosted_contents.create!(:url => "existing url", :title => "a title", :description => "a description")

      BoostedContent.should_receive(:process_boosted_content_xml_upload_for).with(@affiliate, @xml).and_return(false)

      post :bulk, :affiliate_id => @affiliate.to_param, :xml_file => @xml

      response.should redirect_to(new_affiliate_boosted_content_path)
      flash[:error].should =~ /could not be processed/
    end
  end

  describe "lots of bulk content" do
    before :each do
      @affiliate = affiliates(:basic_affiliate)
      UserSession.create(@affiliate.users.first)
      @original_max = Affiliates::BoostedContentsController::MAX_TO_DISPLAY
      @original_to_display = Affiliates::BoostedContentsController::NUMBER_TO_DISPLAY_IF_ABOVE_MAX
      silently do
        Affiliates::BoostedContentsController::MAX_TO_DISPLAY = 3
        Affiliates::BoostedContentsController::NUMBER_TO_DISPLAY_IF_ABOVE_MAX = 2
      end
    end

    after :each do
      silently do
        Affiliates::BoostedContentsController::MAX_TO_DISPLAY = @original_max_boosted_content
        Affiliates::BoostedContentsController::NUMBER_TO_DISPLAY_IF_ABOVE_MAX = @original_to_display
      end
    end

    it "should load limited content if the total exceeds the max" do
      boosted_contents = (0..3).collect { |i| @affiliate.boosted_contents.create(:title => "a title", :description => "a description", :url => "http://url#{i}.com") }

      get :new, :affiliate_id => @affiliate.to_param
      response.should be_success

      assigns(:boosted_content_count).should == 4
      assigns(:boosted_contents).should == [boosted_contents[3], boosted_contents[2]]
    end

    it "load all if below the max" do
      boosted_contents = (0..2).collect { |i| @affiliate.boosted_contents.create(:title => "a title", :description => "a description", :url => "http://url#{i}.com") }

      get :new, :affiliate_id => @affiliate.to_param
      response.should be_success

      assigns(:boosted_content_count).should == 3
      assigns(:boosted_contents).should =~ boosted_contents
    end
  end

  describe "delete all" do
    it "should delete all BoostedContent and redirect to new" do
      affiliate = affiliates(:basic_affiliate)
      UserSession.create(affiliate.users.first)
      3.times { |i| affiliate.boosted_contents.create(:title => "a title", :description => "a description", :url => "http://url#{i}.com") }

      post :destroy_all, :affiliate_id => affiliate.to_param

      response.should redirect_to(new_affiliate_boosted_content_path)

      affiliate.reload.boosted_contents.should be_empty
    end
  end
end
