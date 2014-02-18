require 'spec_helper'

describe SearchesController do
  fixtures :affiliates, :image_search_labels, :document_collections, :rss_feeds, :rss_feed_urls, :navigations, :features, :news_items

  before do
    @affiliate = affiliates(:usagov_affiliate)
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
        response.should render_template 'layouts/searches'
      end

      it "should assign the query as the page title" do
        @page_title.should == "social security - USA.gov Search Results"
      end

      it "should show a custom title for the results page" do
        response.body.should contain("social security - USA.gov Search Results")
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

      it { should assign_to(:search_params).with(
                      hash_including(affiliate: @affiliate.name, query: 'social security')) }
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
    it "should not blow up if affiliate is not a string" do
      get :index, query: 'gov', affiliate: { 'foo' => 'bar' }
      assigns[:affiliate].should == @affiliate
    end

    it "should not blow up if query is not a string" do
      get :index, query: { 'foo' => 'bar' }
      assigns[:search].query.should == %q({"foo"=&gt;"bar"})
    end
  end

  context "when handling a valid affiliate search request" do
    render_views
    before do
      @affiliate = affiliates(:power_affiliate)
      get :index, :affiliate => @affiliate.name, :query => "<script>thunder & lightning</script>"
      @search = assigns[:search]
      @page_title = assigns[:page_title]
    end

    it { should assign_to :affiliate }
    it { should assign_to :page_title }

    it "should sanitize the query term" do
      @search.query.should == "thunder & lightning"
    end

    it "should render the template" do
      response.should render_template 'index'
      response.should render_template 'layouts/searches'
    end

    it "should set an affiliate page title" do
      @page_title.should == "thunder & lightning - Noaa Site Search Results"
    end

    it "should render the header in the response" do
      response.body.should match(/#{@affiliate.header}/)
    end

    it "should render the footer in the response" do
      response.body.should match(/#{@affiliate.footer}/)
    end

    it "should set the sanitized query in Javascript" do
      response.body.should include(%q{var original_query = "thunder & lightning"})
    end
  end

  context "when the affiliate locale is set to Spanish" do
    before do
      affiliate = affiliates(:gobiernousa_affiliate)
      get :index, :affiliate => affiliate.name, :query => 'weather', :locale => 'en'
    end

    it "should override/ignore the HTTP locale param and set locale to Spanish" do
      I18n.locale.to_s.should == 'es'
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
      assigns[:page_title].should == "weather - Noaa Site Search Results"
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
    it { should render_template 'layouts/searches' }
    it { should render_template 'searches/index' }
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
      response.should render_template 'layouts/searches'
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
      response.should render_template 'layouts/searches'
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
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:dc) { mock_model(DocumentCollection) }

    context 'when DocumentCollection exists' do
      let(:site_search) { mock(SiteSearch, :query => 'gov') }

      before do
        Affiliate.should_receive(:find_by_name).and_return(affiliate)
        affiliate.stub_chain(:document_collections, :find_by_id).and_return(dc)
        SiteSearch.should_receive(:new).with(hash_including(dc: '100', per_page: 20)).and_return(site_search)
        site_search.should_receive(:run)
        get :docs, :query => 'gov', :affiliate => affiliate.name, :dc => 100
      end

      it { should assign_to(:affiliate).with(affiliate) }

      it 'should assign various variables' do
        assigns[:page_title].should =~ /gov/
        assigns[:search_vertical].should == :docs
        assigns[:form_path].should == docs_search_path
      end

      it { should assign_to(:search_params).with(
                      hash_including(affiliate: affiliate.name, query: 'gov')) }

      it { should render_template(:docs) }
    end

    context 'when page number is specified' do
      let(:site_search) { mock(SiteSearch, :query => 'pdf') }

      before do
        Affiliate.should_receive(:find_by_name).and_return(affiliate)
        affiliate.stub_chain(:document_collections, :find_by_id).and_return(dc)
        SiteSearch.should_receive(:new).with(hash_including(:dc => '100')).and_return(site_search)
        site_search.should_receive(:run)
        get :docs, :query => 'pdf', :affiliate => affiliate.name, :dc => 100, :page => 3
      end

      specify { assigns[:search_options][:page].should == '3' }
    end

    context 'when DocumentCollection does not exist' do
      let(:web_search) { mock(WebSearch, :query => 'gov') }

      before do
        Affiliate.should_receive(:find_by_name).and_return(affiliate)
        affiliate.stub_chain(:document_collections, :find_by_id).and_return(nil)
        WebSearch.should_receive(:new).with(hash_including(dc: '100', per_page: 20)).and_return(web_search)
        web_search.should_receive(:run)
        SiteSearch.should_not_receive(:new)
        get :docs, :query => 'pdf', :affiliate => affiliate.name, :dc => 100
      end

      it { should assign_to(:affiliate).with(affiliate) }
    end

    context 'when params[:dc] is not a valid number' do
      let(:web_search) { mock(WebSearch, :query => 'gov') }

      before do
        Affiliate.should_receive(:find_by_name).and_return(affiliate)
        affiliate.stub_chain(:document_collections, :find_by_id).with(%q({"foo"=&gt;"bar"})).and_return(nil)
        WebSearch.should_receive(:new).with(hash_including(query: 'pdf')).and_return(web_search)
        web_search.should_receive(:run)
        SiteSearch.should_not_receive(:new)
        get :docs, query: 'pdf', affiliate: affiliate.name, dc: { 'foo' => 'bar' }
      end

      it { should assign_to(:affiliate).with(affiliate) }
    end
  end

  describe "#news" do
    let(:affiliate) { affiliates(:basic_affiliate) }

    before do
      NewsItem.all.each { |news_item| news_item.save! }
      ElasticNewsItem.commit
    end

    it "should assign page title, vertical, form_path, and search members" do
      get :news, :query => "element", :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w", :page => "1", :per_page => "5"
      assigns[:page_title].should == "element - #{affiliate.display_name} Search Results"
      assigns[:search_vertical].should == :news
      assigns[:form_path].should == news_search_path
      assigns[:search].should be_an_instance_of(NewsSearch)
    end

    it "should find news items that match the query for the affiliate" do
      get :news, :query => "element", :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w"
      assigns[:search].total.should == 1
      assigns[:search].results.first.should == news_items(:item1)
      assigns[:search].results.first.title.should == "News \uE000element\uE001 1"
      assigns[:search].results.first.link.should == "http://some.agency.gov/news/1"
      assigns[:search].results.first.published_at.should be_present
      assigns[:search].results.first.description.should == "News \uE000element\uE001 1 has a description"
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
        response.should render_template 'layouts/searches'
      end
    end

    context "when the query is blank and total is > 0" do
      before { get :news, :query => "", :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w" }
      it { should assign_to(:page_title).with('White House Blog - NPS Site Search Results') }
    end

    context "when handling an array parameter" do
      before do
        get :news, {"affiliate"=>affiliate.name, "channel"=>rss_feeds(:white_house_blog).id, "m"=>"false", "query"=>["loren"]}
      end

      it "should render the template" do
        response.should render_template 'news'
        response.should render_template 'layouts/searches'
      end
    end

    context 'when searching with tbs' do
      before do
        Affiliate.should_receive(:find_by_name).with(affiliate.name).and_return(affiliate)
        news_search = mock(NewsSearch, query: 'element', rss_feed: rss_feeds(:white_house_blog))
        news_search.should_receive(:is_a?).with(NewsSearch).and_return(true)
        NewsSearch.should_receive(:new).with(hash_including(tbs: 'w', per_page: 20)).and_return(news_search)
        news_search.should_receive(:run)

        get :news,
            query: 'element',
            affiliate: affiliate.name,
            channel: rss_feeds(:white_house_blog).id,
            tbs: 'w',
            sort_by: 'r',
            contributor: 'The President',
            publisher: 'The White House',
            subject: 'Economy'
      end

      it { should assign_to(:search_params).with(
                      hash_including(affiliate: affiliate.name,
                                     query: 'element',
                                     channel: rss_feeds(:white_house_blog).id,
                                     tbs: 'w',
                                     sort_by: 'r',
                                     contributor: 'The President',
                                     publisher: 'The White House',
                                     subject: 'Economy')) }
    end

    context 'when searching with a date range' do
      let(:channel_id) { rss_feeds(:white_house_blog).id }

      before do
        Affiliate.should_receive(:find_by_name).with(affiliate.name).and_return(affiliate)
        news_search = mock(NewsSearch,
                           query: 'element',
                           rss_feed: rss_feeds(:white_house_blog),
                           since: Time.parse('2012-10-1'),
                           until: Time.parse('2012-10-15'))
        news_search.should_receive(:is_a?).with(NewsSearch).and_return(true)
        NewsSearch.should_receive(:new).
            with(hash_including(since_date: '10/1/2012', until_date:'10/15/2012')).
            and_return(news_search)
        news_search.should_receive(:run)

        get :news, query: 'element', affiliate: affiliate.name, channel: channel_id, tbs: 'w', since_date: '10/1/2012', until_date: '10/15/2012'
      end

      it { should assign_to(:affiliate).with(affiliate) }
      it { should assign_to(:search_options).with(hash_including(since_date: '10/1/2012', until_date:'10/15/2012')) }
      it { should assign_to(:search_params).with(
                      hash_including(affiliate: affiliate.name,
                                     query: 'element',
                                     channel: rss_feeds(:white_house_blog).id,
                                     since_date: '10/01/2012',
                                     until_date: '10/15/2012')) }
    end

    describe "rendering the view" do
      render_views

      it "should render the template" do
        get :news, :query => "element", :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w"
        response.should render_template 'news'
        response.should render_template 'layouts/searches'
      end

      it "should output a page that summarizes the results" do
        get :news, :query => "element", :affiliate => affiliate.name, :channel => rss_feeds(:white_house_blog).id, :tbs => "w"
        response.body.should contain('1 result')
      end
    end
  end

  describe "#video_news" do
    let(:affiliate) { affiliates(:basic_affiliate) }

    context "when the query is not blank" do
      let(:video_news_search) { mock('video news search', query: 'element') }

      before do
        VideoNewsSearch.should_receive(:new).with(hash_including(per_page: 20)).and_return(video_news_search)
        video_news_search.should_receive(:run)
        get :video_news, :query => "element", :affiliate => affiliate.name, :tbs => "w"
      end

      it { should assign_to(:search).with(video_news_search) }
      it { should assign_to(:page_title).with("element - #{affiliate.display_name} Search Results") }
      it { should assign_to(:search_vertical).with(:news) }
      it { should assign_to(:form_path).with(video_news_search_path) }
      it { should render_template(:news) }
      it { should render_template("layouts/searches") }
    end

    context "when the query is blank and total is > 0" do
      let(:video_news_search) { mock('video news search', query: '') }

      before do
        VideoNewsSearch.should_receive(:new).and_return(video_news_search)
        video_news_search.should_receive(:run)
        rss_feed = mock('rss feed', :name => 'Videos')
        video_news_search.should_receive(:rss_feed).at_least(:once).and_return(rss_feed)
        video_news_search.should_receive(:total).and_return(1)
        get :video_news, :query => "", :affiliate => affiliate.name, :channel => '100', :tbs => "w"
      end

      it { should assign_to(:page_title).with('Videos - NPS Site Search Results') }
    end
  end
end
