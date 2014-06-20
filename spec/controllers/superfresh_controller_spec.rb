require 'spec_helper'

describe SuperfreshController, "#index" do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }
  it "should set the request fomat to :rss" do
    get :index
    response.content_type.should == 'application/rss+xml'
  end

  context "when there are no URLs" do
    before do
      SuperfreshUrl.delete_all
    end

    it "should return an empty array" do
      get :index
      assigns[:superfresh_urls].should == []
    end
  end

  context "when there are URLs to return" do
    render_views
    before do
      SuperfreshUrl.delete_all
      (SuperfreshUrl::DEFAULT_URL_COUNT + 1).times do |idx|
        affiliate.superfresh_urls.build(:url => "http://some.mil/x?id=#{idx+1}")
      end
      affiliate.save
    end

    it "should render the first 500 URLs as rss/xml" do
      superfresh_url_first_500 = SuperfreshUrl.first(500)
      get :index
      assigns[:superfresh_urls].should == superfresh_url_first_500
      response.body.should contain(/Search.USA.gov Superfresh Feed/)
      response.body.should contain(/Recently updated URLs from around the US Government/)
      response.body.should contain(/some.mil/)
      response.body.should contain(/500/)
    end

    it "should delete the returned entries" do
      SuperfreshUrl.count.should == 501
      get :index
      SuperfreshUrl.count.should == 1
      get :index
      SuperfreshUrl.count.should == 0
    end
  end
end