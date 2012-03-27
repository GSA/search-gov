require 'spec/spec_helper'

describe SearchesController do
  fixtures :affiliates, :affiliate_templates

  before do
    @affiliate = affiliates(:usagov_affiliate)
  end

  context "when showing index" do
    it "should have a route with a locale" do
      search_path.should =~ /search\?locale=en/
    end
  end

  context "when showing a new search" do
    render_views
    context "when searching in English" do
      before do
        get :index, :query => "social security", :page => 4
        @search = assigns[:search]
        @page_title = assigns[:page_title]
      end

      it "should assign the USA.gov affiliate as the default affiliate" do
        assigns[:affiliate].should == affiliates(:usagov_affiliate)
      end

      it "should render the template" do
        response.should render_template 'index'
        response.should render_template 'layouts/affiliate'
      end

      it "should assign the query as the page title" do
        @page_title.should == "Current social security - USA.gov Search Results"
      end

      it "should show a custom title for the results page" do
        response.body.should contain("Current social security - USA.gov Search Results")
      end

      it "should set the query in the Search model" do
        @search.query.should == "social security"
      end

      it "should set the page" do
        @search.page.should == 4
      end

      it "should load results for a keyword query" do
        @search.should_not be_nil
        @search.results.should_not be_nil
      end
    end

    context "when searching in Spanish" do
      before do
        get :index, :query => "social security", :page => 4, :locale => 'es'
      end

      it "should assign the GobiernoUSA affiliate" do
        assigns[:affiliate].should == affiliates(:gobiernousa_affiliate)
      end
    end
  end

  context "when searching with parameters" do
    it "should not blow up if per-page is blank" do
      get :index, :query => 'white house', "per-page" => ''
      assigns[:search_options][:per_page].should == Search::DEFAULT_PER_PAGE
    end

    it "should not blow up if per-page is not a number" do
      get :index, :query => 'white house', "per-page" => 'number'
      assigns[:search_options][:per_page].should == Search::DEFAULT_PER_PAGE
    end

    it "should not blow up if per page is set to 0" do
      get :index, :query => 'white house', "per-page" => '0'
      assigns[:search_options][:per_page].should == Search::DEFAULT_PER_PAGE
    end

    it "should assign the per page if a valid number" do
      get :index, :query => 'white house', "per-page" => '50'
      assigns[:search_options][:per_page].should == 50
    end
  end

  context "when handling a valid affiliate search request" do
    render_views
    before do
      @affiliate = affiliates(:power_affiliate)
      get :index, :affiliate => @affiliate.name, :query => "<script>weather</script>"
      @search = assigns[:search]
      @page_title = assigns[:page_title]
    end

    it { should assign_to :affiliate }
    it { should assign_to :page_title }

    it "should sanitize the query term" do
      @search.query.should == "weather"
    end

    it "should render the template" do
      response.should render_template 'index'
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

    it "should set the sanitized query in Javascript" do
      response.body.should match(/var original_query = "weather"/)
    end

    context "when the affiliate locale is set to Spanish" do
      before do
        @affiliate.update_attribute(:locale, 'es')
        get :index, :affiliate => @affiliate.name, :query => 'weather', :locale => 'en'
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
    it { should render_template 'searches/index' }
  end

  context "when handling a valid affiliate search request with oneserp=1" do
    let(:affiliate) { affiliates(:basic_affiliate) }

    before do
      Affiliate.should_receive(:find_by_name).with(affiliate.name).and_return(affiliate)
      css_property_hash = mock('css property hash')
      affiliate.should_receive(:css_property_hash).and_return(css_property_hash)
      css_property_hash.should_receive(:[]=).with(:show_content_box_shadow, '1')
      affiliate.should_receive(:uses_one_serp=).with(true)
    end

    it "should set uses_one_serp" do
      get :index, :affiliate => affiliate.name, :query => "weather", :oneserp => 1
    end
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
      response.should render_template 'index'
      response.should render_template 'layouts/affiliate'
    end
  end

  context "when handling an invalid affiliate search request" do
    before do
      get :index, :affiliate=>"doesnotexist.gov", :query => "weather"
      @search = assigns[:search]
    end

    it "should assign the USA.gov affiliate" do
      assigns[:affiliate].should == affiliates(:usagov_affiliate)
    end

    it "should render the template" do
      response.should render_template 'index'
      response.should render_template 'layouts/affiliate'
    end
  end

  context "when handling any affiliate search request with a JSON format" do
    render_views
    before do
      get :index, :affiliate => affiliates(:power_affiliate).name, :query => "weather", :format => "json"
    end

    it "should set the format to json" do
      assigns[:original_format].to_s.should == "application/json"
    end

    it "should serialize the results into JSON" do
      response.body.should =~ /total/
      response.body.should =~ /startrecord/
      response.body.should =~ /endrecord/
    end
  end

  context "when handling embedded affiliate search request" do
    before do
      get :index, :affiliate => affiliates(:power_affiliate).name, :query => "weather", :embedded => "1"
    end

    it "should set embedded search options to true" do
      assigns[:search_options][:embedded].should be_true
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

    context "when the mobile parameter is set to true" do
      before { get :docs, :query => "pdf", :affiliate => @affiliate.name, :m => 'true' }
      it { should respond_with :success }
    end

    it "should assign various variables" do
      get :docs, :query => "pdf", :affiliate => @affiliate.name
      assigns[:page_title].should =~ /pdf/
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
      assigns[:search].hits.first.instance.url.should_not == "http://otheraffiliate.gov/1.pdf"
      assigns[:search].hits.last.instance.url.should_not == "http://otheraffiliate.gov/1.pdf"
    end

    it "should output a page that summarizes the results" do
      get :docs, :query => "pdf", :affiliate => @affiliate.name
      response.body.should contain("Results 1-2 of about 2 for 'pdf'")
    end

    it "should have a 'Results by USASearch' logo" do
      get :docs, :query => "pdf", :affiliate => @affiliate.name
      response.should have_selector("img[src^='/images/results_by_usasearch_en.png']")
      response.should have_selector("a", :href => 'http://usasearch.howto.gov')
    end

    context "when locale is spanish" do
      it "should have a 'Results by USASearch' logo" do
        get :docs, :query => "pdf", :affiliate => @affiliate.name, :locale => 'es'
        response.should have_selector("img[src^='/images/results_by_usasearch_es.png']")
        response.should have_selector("a", :href => 'http://usasearch.howto.gov')
      end
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

    context "when query is blank" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        Affiliate.should_receive(:find_by_name).and_return(affiliate)
        affiliate.should_receive(:build_search_results_page_title).and_return('docs title')
        get :docs, :affiliate => affiliate.name, :dc => '100'
      end

      it { should assign_to(:search).with_kind_of(OdieSearch) }
      it { should assign_to(:page_title).with('docs title') }
    end
  end

  describe "#news" do
    fixtures :affiliates, :rss_feeds, :news_items

    let(:affiliate) { affiliates(:basic_affiliate) }

    before do
      NewsItem.reindex
    end

    it "should assign page title, vertical, form_path, and search members" do
      get :news, :query => "element", :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w"
      assigns[:page_title].should == "Current element - #{affiliate.display_name} Search Results"
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

      it "should assign the USA.gov affiliate" do
        assigns[:affiliate].should == affiliates(:usagov_affiliate)
      end

      it "should render the news template" do
        response.should render_template 'news'
        response.should render_template 'layouts/affiliate'
      end
    end

    describe "rendering the view" do
      render_views

      it "should render the template" do
        get :news, :query => "element", :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w"
        response.should render_template 'news'
        response.should render_template 'layouts/affiliate'
      end

      context "when the mobile parameter is set to true" do
        before {  get :news, :query => 'element', :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :m => 'true' }
        it { should respond_with :success }
      end

      it "should output a page that summarizes the results" do
        get :news, :query => "element", :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w"
        response.body.should contain("Results 1-1 of about 1 for 'element'")
      end

      it "should have a 'Results by USASearch' logo" do
        get :news, :query => 'element', :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w"
        response.should have_selector("img[src^='/images/results_by_usasearch_en.png']")
        response.should have_selector("a", :href => 'http://usasearch.howto.gov')
      end

      context "when the locale is spanish" do
        it "should show a spanish results-by logo" do
          get :news, :query => 'element', :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w", :locale => 'es'
          response.should have_selector("img[src^='/images/results_by_usasearch_es.png']")
          response.should have_selector("a", :href => 'http://usasearch.howto.gov')
        end
      end
    end
  end

  describe "#video_news" do
    fixtures :affiliates, :rss_feeds, :news_items

    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:video_news_search) { mock('video news search') }

    before do
      NewsItem.reindex
      VideoNewsSearch.should_receive(:new).and_return(video_news_search)
      video_news_search.should_receive(:run)
      get :video_news, :query => "element", :affiliate => affiliate.name, :tbs => "w"
    end

    it { should assign_to(:search).with(video_news_search) }
    it { should assign_to(:page_title).with("Current element - #{affiliate.display_name} Search Results") }
    it { should assign_to(:search_vertical).with(:news) }
    it { should assign_to(:form_path).with(video_news_search_path) }
    it { should render_template(:news) }
    it { should render_template("layouts/affiliate") }
  end
end
