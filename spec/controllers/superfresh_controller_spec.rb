require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SuperfreshController do
  describe "#index" do
    render_views
    before do
      @first_uncrawled_url = SuperfreshUrl.create(:url => 'http://some.mil')
      @last_uncrawled_url = SuperfreshUrl.create(:url => 'http://another.mil')
      @already_crawled_url = SuperfreshUrl.create(:url => 'http://already.crawled.mil', :crawled_at => Time.now)
    end

    context "when the request is from the MSNbot" do
      before do
        request.user_agent = SuperfreshUrl::MSNBOT_USER_AGENT
      end

      it "should set the request fomat to :rss, and render as rss/xml" do
        get :index
        assigns[:superfresh_urls].should == [@first_uncrawled_url, @last_uncrawled_url]
        assigns[:superfresh_urls].include?(@already_crawled_url).should be_false
        SuperfreshUrl.uncrawled_urls.should be_empty
        response.content_type.should == 'application/rss+xml'
        response.body.should contain(/Search.USA.gov Superfresh Feed/)
        response.body.should contain(/Recently updated URLs from around the US Government/)
        response.body.should contain(/search.usa.gov/)
        response.body.should contain(/some.mil/)
        response.body.should contain(/another.mil/)
        response.body.should_not contain(/already.crawled.mil/)
      end
    end

    context "when the request is not from the MSNbot" do
      it "should create the superfresh feed, but not update the uncrawled Urls as crawled" do
        get :index
        assigns[:superfresh_urls].should == [@first_uncrawled_url, @last_uncrawled_url]
        assigns[:superfresh_urls].include?(@already_crawled_url).should be_false
        SuperfreshUrl.uncrawled_urls.should_not be_empty
        response.content_type.should == 'application/rss+xml'
        response.body.should contain(/Search.USA.gov Superfresh Feed/)
        response.body.should contain(/Recently updated URLs from around the US Government/)
        response.body.should contain(/search.usa.gov/)
        response.body.should contain(/some.mil/)
        response.body.should contain(/another.mil/)
        response.body.should_not contain(/already.crawled.mil/)
      end
    end

    it "should only show 500 urls" do
      SuperfreshUrl.should_receive(:uncrawled_urls).with(500).and_return []
      get :index
    end

    context "when a feed id is not provided" do
      before do
        get :index
      end

      it "should assign default to the main/first feed" do
        assigns[:feed_id].should == 1
      end
    end

    context "when a feed id is provided" do
      before do
        @uncrawled_urls = SuperfreshUrl.uncrawled_urls(500)
      end

      context "when the feed id is '1'" do
        it "should fetch the first 500 uncrawled URLs" do
          SuperfreshUrl.should_receive(:uncrawled_urls).with(500).and_return @uncrawled_urls
          get :index, :feed_id => "1"
          assigns[:superfresh_urls].should_not be_empty
        end
      end

      context "when the feed id is anything other than '1'" do
        it "should not fetch any uncrawled urls" do
          SuperfreshUrl.should_not_receive(:uncrawled_urls)
          get :index, :feed_id => 3
          assigns[:superfresh_urls].should be_empty
        end
      end
    end
  end
end