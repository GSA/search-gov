require 'spec/spec_helper'

describe SuperfreshController, "#index" do
  it "should set the request fomat to :rss" do
    get :index
    response.content_type.should == 'application/rss+xml'
  end

  context "when a feed id is not provided" do
    it "should assign default to the main/first feed" do
      get :index
      assigns[:feed_id].should == 1
    end
  end

  context "when the feed id is anything other than '1'" do
    it "should assign an empty array" do
      get :index, :feed_id => "3"
      assigns[:superfresh_urls].should == []
    end
  end

  context "when the feed id is '1'" do
    render_views
    before do
      SuperfreshUrl.delete_all
      @first_uncrawled_url = SuperfreshUrl.create(:url => 'http://some.mil')
      @last_uncrawled_url = SuperfreshUrl.create(:url => 'http://another.mil')
      @already_crawled_url = SuperfreshUrl.create(:url => 'http://already.crawled.mil', :crawled_at => Time.now)
    end

    context "when the request is from the MSNbot" do
      before do
        request.user_agent = SuperfreshUrl::MSNBOT_USER_AGENT
      end

      it "should render the deleted entries as rss/xml" do
        SuperfreshUrl.count.should == 3
        get :index
        assigns[:superfresh_urls].should == [@first_uncrawled_url, @last_uncrawled_url]
        SuperfreshUrl.count.should == 1
        response.body.should contain(/Search.USA.gov Superfresh Feed/)
        response.body.should contain(/Recently updated URLs from around the US Government/)
        response.body.should contain(/search.usa.gov/)
        response.body.should contain(/some.mil/)
        response.body.should contain(/another.mil/)
      end
    end

    context "when the request is not from the MSNbot" do
      it "should create the superfresh feed, but not delete the uncrawled Urls" do
        SuperfreshUrl.uncrawled_urls.count.should == 2
        get :index
        assigns[:superfresh_urls].should == [@first_uncrawled_url, @last_uncrawled_url]
        SuperfreshUrl.uncrawled_urls.count.should == 2
        response.body.should contain(/Search.USA.gov Superfresh Feed/)
        response.body.should contain(/Recently updated URLs from around the US Government/)
        response.body.should contain(/search.usa.gov/)
        response.body.should contain(/some.mil/)
        response.body.should contain(/another.mil/)
      end
    end
  end
end