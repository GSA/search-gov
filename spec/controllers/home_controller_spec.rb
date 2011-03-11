require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe HomeController do

  it "should assign a search object" do
    get :index
    assigns[:search].should_not be_nil
  end

  it "should assign a local server hash indicating which datacenter served the request" do
    get :index
    assigns[:rails_sever_location_in_html_comment_for_opsview].should be_instance_of(String)
  end

  context "when no locale is specified" do
    it "should use default locale" do
      get :index
      I18n.locale.should == I18n.default_locale
    end
  end

  it "should assign a top_searches object" do
    top_searches = []
    TopSearch.should_receive(:find_active_entries).and_return(top_searches)
    get :index
    assigns[:active_top_searches].should == top_searches
  end

  context "when valid locale is specified" do
    it "should assign a locale" do
      get :index, :locale=> "es"
      I18n.locale.should == :es
    end
  end

  context "when locale is specified" do
    context "that is invalid" do
      before do
        get :index, :locale=> "hp:webinspect..file*test"
      end
      it "should set locale to :en" do
        I18n.locale.should == :en
      end
    end

    context "that is malicious" do
      before do
        get :index, :locale=> "\0"
      end
      it "should set locale to :en" do
        I18n.locale.should == :en
      end
    end

    context "that is erroneous" do
      before do
        get :index, :locale=> "fr"
      end
      it "should set locale to :en" do
        I18n.locale.should == :en
      end
    end
  end

  describe "#contact_form" do
    it "should display a form in mobile mode" do
      get :contact_form, :m => "true"
      response.should be_success
    end

    it "should return 404 if not in mobile mode" do
      get :contact_form, :m => "false"
      response.status.should == "404 Not Found"
    end

    it "should return 404 if no mode is specified" do
      get :contact_form
      response.status.should == "404 Not Found"
    end
  end
end
