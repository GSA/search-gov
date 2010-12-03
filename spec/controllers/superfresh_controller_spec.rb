require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe SuperfreshController do
  describe "#index" do
    integrate_views
    before do
      @first_uncrawled_url = SuperfreshUrl.create(:url => 'http://some.url')
      @last_uncrawled_url = SuperfreshUrl.create(:url => 'http://another.url')
      @already_crawled_url = SuperfreshUrl.create(:url => 'http://already.crawled.url', :crawled_at => Time.now)
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
        response.body.should contain(/some.url/)
        response.body.should contain(/another.url/)
        response.body.should_not contain(/already.crawled.url/)
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
        response.body.should contain(/some.url/)
        response.body.should contain(/another.url/)
        response.body.should_not contain(/already.crawled.url/)
      end
    end
  end
end