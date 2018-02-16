require 'spec_helper'

describe SuperfreshController, "#index" do
  fixtures :affiliates, :languages
  let(:affiliate) { affiliates(:basic_affiliate) }
  it "should set the request fomat to :rss" do
    get :index
    expect(response.content_type).to eq('application/rss+xml')
  end

  context "when there are no URLs" do
    before do
      SuperfreshUrl.delete_all
    end

    it "should return an empty array" do
      get :index
      expect(assigns[:superfresh_urls]).to eq([])
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
      expect(assigns[:superfresh_urls]).to eq(superfresh_url_first_500)
      expect(response.body).to match(/Search.USA.gov Superfresh Feed/)
      expect(response.body).to match(/Recently updated URLs from around the US Government/)
      expect(response.body).to match(/some.mil/)
      expect(response.body).to match(/500/)
    end

    it "should delete the returned entries" do
      expect(SuperfreshUrl.count).to eq(501)
      get :index
      expect(SuperfreshUrl.count).to eq(1)
      get :index
      expect(SuperfreshUrl.count).to eq(0)
    end
  end
end
