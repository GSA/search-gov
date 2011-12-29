require 'spec/spec_helper'

describe SearchesController do
  fixtures :affiliates, :affiliate_templates

  describe "#auto_complete_for_search_query" do
    it "should use query param to find terms starting with that param" do
      SaytSuggestion.create(:phrase=>"Lorem ipsum dolor sit amet")
      get :auto_complete_for_search_query, :query=>"lorem"
      response.body.should contain(/lorem/i)
    end

    it "should not completely melt down when strange characters are present" do
      lambda { get :auto_complete_for_search_query, :query=>"foo\\" }.should_not raise_error
      lambda { get :auto_complete_for_search_query, :query=>"foo's" }.should_not raise_error
    end

    it "should return empty result if no search param present" do
      get :auto_complete_for_search_query
      response.body.should be_blank
    end

    it "should return empty result if query is just blank spaces" do
      get :auto_complete_for_search_query, :query=>" "
      response.body.should be_blank
    end

    context "when searching in mobile mode" do
      before do
        iphone_user_agent = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
        @regular_user_agent = request.env["HTTP_USER_AGENT"]
        request.env["HTTP_USER_AGENT"] = iphone_user_agent
      end

      it "should return 6 suggestions" do
        Search.should_receive(:suggestions).with(nil, "lorem", 6)
        get :auto_complete_for_search_query, :query=>"lorem"
      end
    end

    context "when searching in nonmobile mode" do
      it "should return 15 suggestions" do
        Search.should_receive(:suggestions).with(nil, "lorem", 15)
        get :auto_complete_for_search_query, :query=>"lorem"
      end
    end

    context "when searching from some other site on the internet" do
      it "should accept the 'q' parameter to work with jQuery's autocomplete syntax when style is set to 'jquery'" do
        SaytSuggestion.create(:phrase => "Lorem ipsum dolor sit amet")
        get :auto_complete_for_search_query, :q =>"lorem", :mode => 'jquery'
        response.body.should contain(/lorem/i)
      end

      it "should return a carriagereturn separated list in jquery mode" do
        SaytSuggestion.create(:phrase => "Lorem ipsum dolor sit amet")
        SaytSuggestion.create(:phrase => "Lorem sic transit gloria")
        get :auto_complete_for_search_query, :q => "lorem", :mode => 'jquery', :callback => 'jsonp'
        response.body.should == 'jsonp(["lorem ipsum dolor sit amet","lorem sic transit gloria"])'
      end
    end
  end

  context "when showing index" do
    it "should have a route with a locale" do
      search_path.should =~ /search\?locale=en/
    end
  end

  context "when showing a new search" do
    render_views
    before do
      get :index, :query => "social security", :page => 4
      @search = assigns[:search]
      @page_title = assigns[:page_title]
    end

    it "should render the template" do
      response.should render_template 'index'
      response.should render_template 'layouts/application'
    end

    it "should assign the query as the page title" do
      @page_title.should == "social security"
    end

    it "should show a custom title for the results page" do
      response.body.should contain("social security - Search.USA.gov")
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
    render_views
    before do
      @affiliate = affiliates(:power_affiliate)
      get :index, :affiliate=>@affiliate.name, :query => "weather"
      @search = assigns[:search]
      @page_title = assigns[:page_title]
    end

    it { should assign_to :affiliate }
    it { should assign_to :page_title }

    it "should render the template" do
      response.should render_template 'affiliate_index'
      response.should render_template 'layouts/affiliate'
    end

    it "should set an affiliate page title" do
      @page_title.should == "Current weather - Noaa Site Search Results"
    end

    it "should render the header in the response" do
      response.body.should match(/#{@affiliate.header}/)
    end

    it "should render the footer in the response" do
      response.body.should match(/#{@affiliate.footer}/)
    end

    it "should not search for FAQs" do
      @search.faqs.should be_nil
      response.body.should_not contain(/related_faqs/)
    end

    context "when a scope id is provided do" do
      before do
        get :index, :affiliate => @affiliate.name, :query => 'weather', :scope_id => 'SomeScope'
      end

      it "should set the scope id variable" do
        assigns[:scope_id].should == 'SomeScope'
      end
    end

    context "when the affiliate locale is set to Spanish" do
      before do
        @affiliate.update_attribute(:locale, 'es')
        get :index, :affiliate => @affiliate.name, :query => 'weather', :scope_id => 'SomeScope', :locale => 'en'
      end

      it "should override/ignore the HTTP locale param and set locale to Spanish" do
        I18n.locale.to_s.should == 'es'
      end
    end
  end

  context "when handling a valid staged affiliate search request" do
    render_views
    before do
      @affiliate = affiliates(:power_affiliate)
    end

    it "should maintain the staged parameter for future searches" do
      get :index, :affiliate => @affiliate.name, :query => "weather", :staged => 1
      response.body.should have_selector("input[type='hidden'][value='1'][name='staged']")
    end

    it "should set an affiliate page title" do
      get :index, :affiliate => @affiliate.name, :query => "weather", :staged => 1
      assigns[:page_title].should == "Staged weather - Noaa Site Search Results"
    end
  end

  context "when handling a valid affiliate search request with mobile device" do
    let(:affiliate) { affiliates(:power_affiliate) }

    before do
      iphone_user_agent = "Mozilla/5.0 (iPhone; U; CPU like Mac OS X; en) AppleWebKit/420+ (KHTML, like Gecko) Version/3.0 Mobile/1A543a Safari/419.3"
      request.env["HTTP_USER_AGENT"] = iphone_user_agent
      get :index, :affiliate => affiliate.name, :query => "weather"
    end

    it { should respond_with(:success) }
    it { should render_template 'layouts/affiliate' }
    it { should render_template 'searches/affiliate_index' }
  end

  context "when searching via the API" do
    render_views

    context "when searching normally" do
      before do
        get :index, :query => 'weather', :format => "json"
        @search = assigns[:search]
        @format = assigns[:original_format]
      end

      it "should set the format to json" do
        @format.to_s.should == "application/json"
      end

      it "should serialize the results into JSON" do
        response.body.should =~ /total/
        response.body.should =~ /startrecord/
        response.body.should =~ /endrecord/
      end
    end

    context "when some error is returned" do
      before do
        get :index, :query => 'a' * 1001, :format => "json"
        @search = assigns[:search]
      end

      it "should serialize an error into JSON" do
        response.body.should =~ /error/
        response.body.should =~ /#{I18n.translate :too_long}/
      end
    end
  end

  context "when handling any affiliate search request (mobile or otherwise)" do
    render_views
    before do
      get :index, :affiliate=> affiliates(:power_affiliate).name, :query => "weather"
    end

    it "should render the template" do
      response.should render_template 'affiliate_index'
      response.should render_template 'layouts/affiliate'
    end
  end

  context "when handling an invalid affiliate search request" do
    before do
      get :index, :affiliate=>"doesnotexist.gov", :query => "weather"
      @search = assigns[:search]
    end

    it "should render the template" do
      response.should render_template 'index'
      response.should render_template 'layouts/application'
    end
  end

  context "when handling any affiliate search request with a JSON format" do
    render_views
    before do
      get :index, :affiliate => affiliates(:power_affiliate).name, :query => "weather", :format => "json"
    end

    it { should respond_with :not_acceptable }
  end

  context "when handling embedded affiliate search request" do
    before do
      get :index, :affiliate => affiliates(:power_affiliate).name, :query => "weather", :embedded => "1"
    end

    it "should set embedded search options to true" do
      assigns[:search_options][:embedded].should be_true
    end
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

  context "when handling a request that has FAQ results, but the FAQ records have been deleted from the database" do
    render_views
    before do
      Faq.destroy_all
      Faq.reindex
      Sunspot.commit
      Faq.search_for('uspto').total.should == 0
      @faq = Faq.create(:question => 'What is the USPTO?', :answer => 'The USPTO is a government agency', :url => 'http://uspto.gov', :ranking => 1)
      Sunspot.commit
      Faq.search_for('uspto').total.should == 1
      Faq.delete_all
      Faq.search_for('uspto').total.should == 1
      get :index, :query => 'uspto'
    end

    it "should display search results without Faq results" do
      response.should be_success
    end
  end

  context "when a user is attempting to visit an old-style advanced search page" do
    before do
      get :index, :form => "advanced-firstgov"
    end

    it "should redirect to the advanced search page" do
      response.should redirect_to advanced_search_path(:form => 'advanced-firstgov')
    end
  end

  context "when a user is attempting to visit an old-style advanced search page for an affiliate" do
    before do
      get :index, :form => 'advanced-firstgov', :affiliate => 'aff.gov'
    end

    it "should redirect to the affiliate advanced search page" do
      response.should be_redirect
      redirect_to advanced_search_path(:affiliate => 'aff.gov', :form => 'advanced-firstgov')
    end
  end

  context "highlighting" do
    context "when a client requests results without highlighting" do
      before do
        get :index, :query => "obama", :hl => "false"
      end

      it "should set the highlighting option to false" do
        @search_options = assigns[:search_options]
        @search_options[:enable_highlighting].should be_false
      end
    end

    context "when a client requests result with highlighting" do
      before do
        get :index, :query => "obama", :hl => "true"
      end

      it "should set the highlighting option to true" do
        @search_options = assigns[:search_options]
        @search_options[:enable_highlighting].should be_true
      end
    end

    context "when a client does not specify highlighting" do
      before do
        get :index, :query => "obama"
      end

      it "should set the highlighting option to true" do
        @search_options = assigns[:search_options]
        @search_options[:enable_highlighting].should be_true
      end
    end
  end

  context "when omitting search textbox" do
    it "should omit the search textbox if the show_searchbox parameter is set to false and mobile mode is true" do
      get :index, :query => "obama", :show_searchbox => "false"
      assigns[:show_searchbox].should be_false
      response.body.should_not have_selector "search_form"
    end
  end

  describe "#advanced" do
    context "when viewing advanced search page" do
      before do
        get :advanced
      end

      it { should assign_to(:page_title).with_kind_of(String) }
    end

    context "when viewing an affiliate advanced search page" do
      before do
        get :advanced, :affiliate => affiliates(:basic_affiliate).name
      end

      it { should assign_to(:page_title).with_kind_of(String) }
    end

    context "when an affiliate advanced search form is displayed" do
      context "when a valid scope id is specified" do
        before do
          get :index, :affiliate=> affiliates(:power_affiliate).name, :query => "weather", :scope_id => 'PatentClass'
        end

        it "should assign the scope id" do
          assigns[:scope_id].should == 'PatentClass'
        end
      end
    end
  end

  describe "#forms" do
    render_views

    context "when the source parameter is not specified" do
      before do
        get :forms, :query => "taxes", :page => 2
        @search = assigns[:search]
        @page_title = assigns[:page_title]
      end

      it "should render the template" do
        response.should render_template 'index'
        response.should render_template 'layouts/application'
      end

      it "should show the forms logo" do
        response.should have_selector("img[src^='/images/USAsearch_medium_en_forms.gif']")
      end

      it "should assign the query with a forms prefix as the page title" do
        @page_title.should == "taxes"
      end

      it "should show a custom title for the results page" do
        response.body.should contain("taxes - Search.USA.gov Forms")
      end

      it "should set the query in the Search model" do
        @search.query.should == "taxes"
      end

      it "should offset the start page in the Search model by one" do
        @search.page.should == 1
      end

      it "should load results for a keyword query" do
        @search.should_not be_nil
        @search.results.should_not be_nil
      end

      it "should use the FormSearch model to do the search" do
        form_search_results = FormSearch.new(:query => 'taxes')
        FormSearch.should_receive(:new).with(:results_per_page => nil, :query => "taxes", :enable_highlighting => true, :page => 1).and_return form_search_results
        get :forms, :query => "taxes", :page => 2
      end

      it "should render the search box with the form search path" do
        response.body.should have_selector("form[id='search_form']", :method => 'get', :action => '/search/forms?locale=en&m=false')
      end

      it "should not show any related search results" do
        @search.related_search.should be_empty
      end

      it "should have a Forms header at the top of the results, and link to Government Web and Images" do
        response.body.should have_selector("a", :href => "/search?m=false&query=taxes", :content => "Web")
        response.body.should have_selector("a", :href => '/search/images?m=false&query=taxes', :content => "Images")
        response.body.should have_selector("span", :content => "Forms")
      end

      it "should not have related Gov Forms" do
        response.body.should_not have_selector("ul[id=related_gov_forms]")
      end
    end

    context "when the query is blank" do
      it "should redirect to the forms landing page" do
        get :forms
        response.should redirect_to forms_path
      end
    end
  end

  describe "#docs" do
    render_views
    before do
      IndexedDocument.delete_all
      @affiliate = affiliates(:basic_affiliate)
      @affiliate.indexed_documents << IndexedDocument.new(:title => "Affiliate PDF 1", :url => 'http://affiliate.gov/1.pdf', :description => 'a pdf', :doctype => 'pdf', :last_crawl_status => IndexedDocument::OK_STATUS)
      @affiliate.indexed_documents << IndexedDocument.new(:title => "Affiliate PDF 2", :url => 'http://affiliate.gov/2.pdf', :description => 'a pdf', :doctype => 'pdf', :last_crawl_status => IndexedDocument::OK_STATUS)
      affiliates(:power_affiliate).indexed_documents << IndexedDocument.new(:title => "Other Affiliate PDF 1", :url => 'http://otheraffiliate.gov/1.pdf', :description => 'a pdf', :doctype => 'pdf', :last_crawl_status => IndexedDocument::OK_STATUS)
      IndexedDocument.reindex
      Sunspot.commit
    end

    it "should render the template" do
      get :docs, :query => "pdf", :affiliate => @affiliate.name
      response.should render_template 'docs'
      response.should render_template 'layouts/affiliate'
    end

    it "should assign various variables" do
      get :docs, :query => "pdf", :affiliate => @affiliate.name
      assigns[:page_title].should == "pdf"
      assigns[:search_vertical].should == :docs
      assigns[:form_path].should == docs_search_path
      assigns[:search].should_not be_nil
    end

    it "should default to page 1" do
      get :docs, :query => "pdf", :affiliate => @affiliate.name
      assigns[:search_options][:page].should == 1
    end

    it "should find PDF files that match the query for the affiliate" do
      get :docs, :query => "pdf", :affiliate => @affiliate.name
      assigns[:search].total.should == 2
      assigns[:search].results.first.url.should_not == "http://otheraffiliate.gov/1.pdf"
      assigns[:search].results.last.url.should_not == "http://otheraffiliate.gov/1.pdf"
    end

    it "should output a page that summarizes the results and links back to the affiliate results page" do
      get :docs, :query => "pdf", :affiliate => @affiliate.name
      response.body.should contain("Results 1-2 of about 2 for 'pdf'")
      response.should have_selector("a", :href=> '/search?affiliate=NPS+Site&locale=en&m=false&query=pdf', :content => 'Back to all NPS Site results >>')
    end

    context "when the page number is specified" do
      before do
        get :docs, :query => "pdf", :affiliate => @affiliate.name, :page => 2
      end

      it "should page the results" do
        assigns[:search_options][:page].should == 2
        assigns[:search].total.should == 2
        assigns[:search].results.should be_empty
      end
    end
  end

  describe "#news" do
    fixtures :affiliates, :rss_feeds, :news_items, :calais_related_searches

    let(:affiliate) { affiliates(:basic_affiliate) }

    before do
      NewsItem.reindex
      CalaisRelatedSearch.reindex
    end

    it "should assign page title, vertical, form_path, and search members" do
      get :news, :query => "element", :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w"
      assigns[:page_title].should == "element"
      assigns[:search_vertical].should == :news
      assigns[:form_path].should == news_search_path
      assigns[:search].should be_an_instance_of(NewsSearch)
    end

    it "should find news items that match the query for the affiliate" do
      get :news, :query => "element", :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w"
      assigns[:search].total.should == 1
      assigns[:search].results.first.should == news_items(:item1)
    end

    context "when the affiliate does not exist" do
      before do
        get :news, :query => "element", :affiliate => "donotexist", :channel => rss_feeds(:white_house_blog).id, :tbs => "w"
      end
      it { should redirect_to root_path }
    end

    describe "rendering the view" do
      render_views

      it "should render the template" do
        get :news, :query => "element", :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w"
        response.should render_template 'news'
        response.should render_template 'layouts/affiliate'
      end

      it "should output a page that summarizes the results" do
        get :news, :query => "element", :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w"
        response.body.should contain("Results 1-1 of about 1 for 'element'")
      end
    end
  end

end