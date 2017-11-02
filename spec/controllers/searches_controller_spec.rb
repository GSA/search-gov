require 'spec_helper'

describe SearchesController do
  fixtures :affiliates, :image_search_labels, :document_collections, :rss_feeds, :rss_feed_urls,
           :navigations, :features, :news_items, :languages

  let(:affiliate) { affiliates(:usagov_affiliate) }

  context "when showing a new search" do
    render_views
    context "when searching in English" do
      before do
        get :index, query: 'social security', page: 4, affiliate: 'usagov'
        @search = assigns[:search]
        @page_title = assigns[:page_title]
      end

      it 'should assign to search_options a Hash with only Symbol keys' do
        expect(@controller.view_assigns['search_options'].keys.map(&:class).uniq).to eq([Symbol])
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
        response.body.should match(/social security - USA.gov Search Results/)
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
                      hash_including(affiliate: affiliate.name, query: 'social security')) }
    end

    context 'when searching on a Spanish site' do
      it 'assigns locale to :es' do
        I18n.should_receive(:locale=).with(:es)
        get :index, query: 'social security', page: 4, affiliate: 'gobiernousa'
      end
    end
  end

  context 'when affiliate is not valid' do
    before { get :index, query: 'gov', affiliate: { 'foo' => 'bar' } }
    it { should redirect_to 'https://www.usa.gov/page-not-found' }
  end

  context 'when the affiliate is not active' do
    let(:affiliate) { affiliates(:inactive_affiliate) }
    before { get :index, query: 'gov', affiliate: affiliate.name }

    it { should redirect_to 'https://www.usa.gov/page-not-found' }
  end

  context 'when searching with non scalar query' do
    it "should not blow up if query is not a string" do
      get :index, query: { 'foo' => 'bar' }, affiliate: 'usagov'
      assigns[:search].query.should be_blank
    end
  end

  context 'when search_consumer_search_enabled is true' do
    let(:affiliate) { affiliates(:search_consumer_affiliate) }

    it 'should redirect to the search-consumer display page' do
      get :index, query: 'matzo balls', affiliate: affiliate.name
      response.should redirect_to search_consumer_search_url({query: 'matzo balls', affiliate: affiliate.name})
    end
  end

  context 'searching on a routed keyword' do
    let(:affiliate) { affiliates(:basic_affiliate) }
    context 'referrer does not match redirect url' do
      before do
        routed_query = affiliate.routed_queries.build(url: "http://www.gov.gov/foo.html", description: "testing")
        routed_query.routed_query_keywords.build(keyword: 'foo bar')
        routed_query.save!
      end

      it 'redirects to the proper url' do
        get :index, query: "foo bar", affiliate: affiliate.name
        response.should redirect_to 'http://www.gov.gov/foo.html'
      end

      it 'logs the impression' do
        SearchImpression.should_receive(:log)
        get :index, query: "foo bar", affiliate: affiliate.name
      end
    end

    context 'referrer matches redirect url' do
      let(:ref_url) { 'http://www.gov.gov/foo.html' }
      let(:rq_url) { 'http://www.gov.gov/foo.html' }

      shared_examples_for 'a routed query that matches the referrer' do
        before do
          routed_query = affiliate.routed_queries.build(url: rq_url, description: "testing")
          routed_query.routed_query_keywords.build(keyword: 'foo bar')
          routed_query.save!
          request.env['HTTP_REFERER'] = ref_url
          get :index, query: "foo bar", affiliate: affiliate.name
        end

        it { should render_template(:index) }
      end

      it_should_behave_like 'a routed query that matches the referrer'

      context 'when the match is exact except that the referring URL is http and the routed query URL is https' do
        let(:rq_url) { 'https://www.gov.gov/foo.html' }
        it_should_behave_like 'a routed query that matches the referrer'
      end

      context 'when the match is exact except that the referring URL is https and the routed query URL is http' do
        let(:ref_url) { 'https://www.gov.gov/foo.html' }
        it_should_behave_like 'a routed query that matches the referrer'
      end
    end
  end

  context 'when affiliate gets i14y results' do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:i14y_search) { double(I14ySearch, :query => 'gov', :modules => %w(I14Y), :diagnostics => {}) }

    before do
      Affiliate.should_receive(:find_by_name).and_return(affiliate)
      affiliate.gets_i14y_results = true
      I14ySearch.should_receive(:new).and_return(i14y_search)
      i14y_search.should_receive(:run)
      get :index, :query => 'gov', :affiliate => affiliate.name
    end

    it { should assign_to(:affiliate).with(affiliate) }

    it 'should assign various variables' do
      assigns[:page_title].should =~ /gov/
      assigns[:search_vertical].should == :i14y
    end

    it { should assign_to(:search_params).with(
                  hash_including(affiliate: affiliate.name, query: 'gov')) }

    it { should render_template(:i14y) }

  end

  context 'when affiliate is using SearchGov' do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:i14y_search) { double(I14ySearch, :query => 'gov', :modules => %w(I14Y), :diagnostics => {}) }

    before do
      Affiliate.should_receive(:find_by_name).and_return(affiliate)
      affiliate.search_engine = 'SearchGov'
      I14ySearch.should_receive(:new).and_return(i14y_search)
      i14y_search.should_receive(:run)
      get :index, :query => 'gov', :affiliate => affiliate.name
    end

    it { should assign_to(:affiliate).with(affiliate) }

    it 'should assign various variables' do
      assigns[:page_title].should =~ /gov/
      assigns[:search_vertical].should == :i14y
    end

    it { should assign_to(:search_params).with(
                  hash_including(affiliate: affiliate.name, query: 'gov')) }

    it { should render_template(:i14y) }
  end

  context 'when handling a valid affiliate search request on legacy SERP' do
    render_views
    let(:affiliate) { affiliates(:legacy_affiliate) }

    before do
      get :index, :affiliate => affiliate.name, :query => "<script>thunder & lightning</script>"
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
      @page_title.should == 'thunder & lightning - Legacy Search Results'
    end

    it "should render the header in the response" do
      response.body.should match(/#{affiliate.header}/)
    end

    it "should render the footer in the response" do
      response.body.should match(/#{affiliate.footer}/)
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
    let(:affiliate) { affiliates(:power_affiliate) }

    it "should maintain the staged parameter for future searches" do
      get :index, :affiliate => affiliate.name, :query => "weather", :staged => 1
      response.body.should have_selector("input[type='hidden'][value='1'][name='staged']")
    end

    it "should set an affiliate page title" do
      get :index, :affiliate => affiliate.name, :query => "weather", :staged => 1
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
        get :index, :query => 'weather', :format => "json", affiliate: 'usagov'
        @search = assigns[:search]
      end

      it "should serialize the results into JSON" do
        response.body.should =~ /total/
        response.body.should =~ /startrecord/
        response.body.should =~ /endrecord/
      end
    end

    context "when some error is returned" do
      before do
        get :index, :query => 'a' * 1001, :format => "json", affiliate: 'usagov'
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
    end

    it { should redirect_to 'https://www.usa.gov/page-not-found' }
  end

  context "when handling any affiliate search request with a JSON format" do
    render_views
    before do
      get :index, :affiliate => affiliates(:power_affiliate).name, :query => "weather", :format => "json"
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
        get :index, :query => "obama", :hl => "false", affiliate: 'usagov'
      end

      it "should set the highlighting option to false" do
        @search_options = assigns[:search_options]
        @search_options[:enable_highlighting].should be false
      end
    end

    context "when a client requests result with highlighting" do
      before do
        get :index, :query => "obama", :hl => "true", affiliate: 'usagov'
      end

      it "should set the highlighting option to true" do
        @search_options = assigns[:search_options]
        @search_options[:enable_highlighting].should be true
      end
    end

    context "when a client does not specify highlighting" do
      before do
        get :index, :query => "obama", affiliate: 'usagov'
      end

      it "should set the highlighting option to true" do
        @search_options = assigns[:search_options]
        @search_options[:enable_highlighting].should be true
      end
    end
  end

  context 'when Affiliate.force_mobile_format = true' do
    let(:affiliate) { affiliates(:basic_affiliate) }

    before do
      Affiliate.should_receive(:find_by_name).and_return(affiliate)
      affiliate.should_receive(:force_mobile_format?).and_return(true)
      request.should_receive(:format=).with(:mobile)
      get :index, query: 'gov', affiliate: affiliate.name, m: 'true'
    end

    it { should render_template 'layouts/searches' }
    it { should render_template 'searches/index' }
  end

  describe "#advanced" do
    before { get :advanced, affiliate: 'usagov' }

    it { should assign_to(:page_title).with_kind_of(String) }
  end

  describe "#docs" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:dc) { mock_model(DocumentCollection) }

    context 'when DocumentCollection exists' do
      let(:site_search) { double(SiteSearch, :query => 'gov', :modules => %w(BWEB), :diagnostics => {}) }

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
      let(:site_search) { double(SiteSearch, :query => 'pdf', :modules => [], :diagnostics => {}) }

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
      let(:web_search) { double(WebSearch, :query => 'gov', :modules => [], :diagnostics => {}) }

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
      let(:web_search) { double(WebSearch, :query => 'gov', :modules => [], :diagnostics => {}) }

      before do
        Affiliate.should_receive(:find_by_name).and_return(affiliate)
        affiliate.stub_chain(:document_collections, :find_by_id).with(nil).and_return(nil)
        WebSearch.should_receive(:new).with(hash_including(query: 'pdf')).and_return(web_search)
        web_search.should_receive(:run)
        SiteSearch.should_not_receive(:new)
        get :docs, query: 'pdf', affiliate: affiliate.name, dc: { 'foo' => 'bar' }
      end

      it { should assign_to(:affiliate).with(affiliate) }
    end

    context 'when the affiliate is search-consumer enabled' do
      let(:affiliate) { affiliates(:search_consumer_affiliate) }
      let(:docs_search_params) do
        { query: 'matzo balls', affiliate: affiliate.name, dc: 100 }
      end

      it 'should redirect to the search-consumer display page' do
        get :docs, docs_search_params
        response.should redirect_to search_consumer_docs_search_url(docs_search_params)
      end
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

      it { should redirect_to 'https://www.usa.gov/page-not-found' }
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
        news_search = double(NewsSearch,
                           query: 'element',
                           rss_feed: rss_feeds(:white_house_blog),
                           modules: [],
                           tbs: 'w',
                           :diagnostics => {})
        news_search.should_receive(:is_a?).with(FilterableSearch).and_return(true)
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
        news_search = double(NewsSearch,
                           query: 'element',
                           rss_feed: rss_feeds(:white_house_blog),
                           modules: [],
                           tbs: nil,
                           since: Time.parse('2012-10-1'),
                           until: Time.parse('2012-10-15'),
                           diagnostics: {})
        news_search.should_receive(:is_a?).with(FilterableSearch).and_return(true)
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
    end

    context 'when the affiliate is search-consumer enabled' do
      let(:affiliate) { affiliates(:search_consumer_affiliate) }
      let(:news_search_params) do
        { query: 'matzo balls', affiliate: affiliate.name, channel: 3 }
      end

      it 'should redirect to the search-consumer display page' do
        get :news, news_search_params
        response.should redirect_to search_consumer_news_search_url(news_search_params)
      end
    end
  end

  describe "#video_news" do
    let(:affiliate) { affiliates(:basic_affiliate) }

    context "when the query is not blank" do
      let(:video_news_search) { double('video news search', query: 'element', modules: [], diagnostics: {}) }

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
      let(:video_news_search) { double('video news search', query: '', modules: [], diagnostics: {}) }

      before do
        VideoNewsSearch.should_receive(:new).and_return(video_news_search)
        video_news_search.should_receive(:run)
        rss_feed = double('rss feed', :name => 'Videos')
        video_news_search.should_receive(:rss_feed).at_least(:once).and_return(rss_feed)
        video_news_search.should_receive(:total).and_return(1)
        get :video_news, :query => "", :affiliate => affiliate.name, :channel => '100', :tbs => "w"
      end

      it { should assign_to(:page_title).with('Videos - NPS Site Search Results') }
    end
  end
end
