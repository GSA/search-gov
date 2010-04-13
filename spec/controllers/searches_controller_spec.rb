require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SearchesController do
  fixtures :affiliates, :affiliate_templates

  describe "#auto_complete_for_search_query" do
    it "should use query param to find terms starting with that param" do
      SaytSuggestion.create(:phrase=>"Lorem ipsum dolor sit amet")
      get :auto_complete_for_search_query, :query=>"lorem"
      response.body.should match(/lorem/i)
    end

    it "should not completely melt down when strange characters are present" do
      lambda {get :auto_complete_for_search_query, :query=>"foo\\"}.should_not raise_error
      lambda {get :auto_complete_for_search_query, :query=>"foo's"}.should_not raise_error
    end

    it "should return empty result if no search param present" do
      get :auto_complete_for_search_query
      response.body.should be_blank
    end

    context "when searching in mobile mode" do
      before do
        @there_must_be_a_better_way_to_stub_this = ActionController::MobileFu::MOBILE_USER_AGENTS
        module ActionController::MobileFu
          remove_const :MOBILE_USER_AGENTS
        end
        ActionController::MobileFu::MOBILE_USER_AGENTS = "."
      end

      it "should return 6 suggestions" do
        Search.should_receive(:suggestions).with("lorem", 6)
        get :auto_complete_for_search_query, :query=>"lorem"
      end

      after do
        module ActionController::MobileFu
          remove_const :MOBILE_USER_AGENTS
        end
        ActionController::MobileFu::MOBILE_USER_AGENTS = @there_must_be_a_better_way_to_stub_this
      end
    end

    context "when searching in non-mobile mode" do
      it "should return 15 suggestions" do
        Search.should_receive(:suggestions).with("lorem", 15)
        get :auto_complete_for_search_query, :query=>"lorem"
      end
    end

  end

  context "when showing index" do
    it "should have a route with a locale" do
      search_path.should =~ /search\?locale=en/
    end
  end

  context "when showing a new search" do
    integrate_views
    before do
      get :index, :query => "social security", :page => 4
      @search = assigns[:search]
      @page_title = assigns[:page_title]
    end

    should_render_template 'searches/index.html.haml', :layout => 'application'

    should_assign_to :page_title

    it "should assign the query as the page title" do
      @page_title.should == "social security"
    end

    it "should show a custom title for the results page" do
      response.body.should contain("social security - The U.S. Government's Official Web Search")
    end

    it "should set the query in the Search model" do
      @search.query.should == "social security"
    end

    it "should offset the start page in the Search model by one" do
      @search.page.should == 3
    end

    it "should load results for a keyword query" do
      @search.should_not be_nil
      @search.results.should_not be_nil
    end
  end

  context "when handling a valid affiliate search request" do
    integrate_views
    before do
      @affiliate = affiliates(:power_affiliate)
      get :index, :affiliate=>@affiliate.name, :query => "weather"
      @search = assigns[:search]
      @page_title = assigns[:page_title]
    end

    should_assign_to :affiliate
    should_assign_to :page_title

    should_render_template 'searches/affiliate_index.html.haml', :layout => 'affiliate'

    it "should set an affiliate page title" do
      @page_title.should == "Search.USA.gov search results for #{@affiliate.name}: #{@search.query}"
    end

    it "should render the header in the response" do
      response.body.should match(/#{@affiliate.header}/)
    end

    it "should render the footer in the response" do
      response.body.should match(/#{@affiliate.footer}/)
    end

    it "should not search for FAQs" do
      @search.faqs.should be_nil
      response.body.should_not match(/related_faqs/)
    end

    it "should not search for GovForms" do
      @search.gov_forms.should be_nil
      response.body.should_not match(/related_gov_forms/)
    end

  end

  context "when handling any affiliate search request (mobile or otherwise)" do
    integrate_views
    before do
      get :index, :affiliate=> affiliates(:power_affiliate).name, :query => "weather"
    end

    should_render_template 'searches/affiliate_index.html.haml', :layout => 'affiliate'
  end

  context "when handling an invalid affiliate search request" do
    before do
      get :index, :affiliate=>"doesnotexist.gov", :query => "weather"
      @search = assigns[:search]
    end

    should_render_template 'searches/index.html.haml', :layout => 'application'

  end

  context "when handling a request that has FAQ results" do
    before do
      get :index, :query => 'uspto'
      @search = assigns[:search]
    end

    it "should search for FAQ results" do
      @search.should_not be_nil
      @search.faqs.should_not be_nil
    end
  end

  context "when handling a request that has GovForm results" do
    before do
      get :index, :query => 'shell egg'
      @search = assigns[:search]
    end

    it "should search for GovForm results" do
      @search.should_not be_nil
      @search.gov_forms.should_not be_nil
    end
  end

  context "when handling a search based on an SAYT suggestion" do
    before do
      get :index, :query => 'very suggestive', :sayt => true
    end

    it "should record the accepted suggestion" do
      AcceptedSaytSuggestion.find_by_phrase('very suggestive').should_not be_nil
    end
  end

  context "when handling a search NOT based on an SAYT suggestion" do
    before do
      get :index, :query => 'very suggestive'
    end

    it "should NOT record the accepted suggestion" do
      AcceptedSaytSuggestion.find_by_phrase('very suggestive').should be_nil
    end
  end

end
