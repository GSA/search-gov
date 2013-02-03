require 'spec_helper'

describe ApiController do
  fixtures :affiliates, :users, :site_domains, :features

  describe "#search" do
    context "when the affiliate does not exist" do
      before { get :search, affiliate: 'missingaffiliate' }

      it { should respond_with :not_found }
    end

    context 'when the params[:affiliate] is not a string' do
      before { get :search, affiliate: { 'foo' => 'bar' } }

      it { should respond_with :not_found }
    end

    describe "with format=json" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        get :search, :affiliate => affiliate.name, :format => 'json', :query => 'solar'
      end

      it { should respond_with_content_type :json }
      it { should respond_with :success }

      describe "response body" do
        subject { JSON.parse(response.body) }
        its(['total']) { should be > 0 }
        its(['startrecord']) { should == 1 }
        its(['endrecord']) { should == 10 }
        its(['results']) { should_not be_empty }
      end
    end

    context "with format=xml" do
      let(:affiliate) { affiliates(:basic_affiliate) }

      before do
        get :search, :affiliate => affiliate.name, :format => 'xml', :query => 'solar'
      end

      it { should respond_with_content_type :xml }
      it { should respond_with :success }

      describe "response body" do
        subject { Hash.from_xml(response.body)["search"] }

        its(['total']) { should be > 0 }
        its(['startrecord']) { should == 1 }
        its(['endrecord']) { should == 10 }
        its(['results']) { should_not be_empty }
      end
    end

    context "with format=html" do
      before do
        get :search, :affiliate => affiliates(:basic_affiliate).name, :format => :html
      end

      it { should respond_with :not_acceptable }
    end

    describe "options" do
      before :each do
        @auth_params = { :affiliate => affiliates(:basic_affiliate).name }
      end

      it "should set the affiliate" do
        get :search, @auth_params
        assigns[:search_options][:affiliate].should == affiliates(:basic_affiliate)
      end

      it "should set the query" do
        get :search, @auth_params.merge(:query => "fish")
        assigns[:search_options][:query].should == "fish"
      end
    end

    describe "boosted content" do
      it "should include boosted content if found" do
        affiliate = affiliates(:basic_affiliate)
        affiliate.boosted_contents.create!(:title => "title",
                                           :url => "http://example.com",
                                           :description => "description",
                                           :status => 'active',
                                           :publish_start_on => Date.yesterday)
        BoostedContent.reindex

        get :search, :affiliate => affiliate.name, :query => "title", :format => 'json'

        boosted_results = JSON.parse(response.body)["boosted_results"]
        boosted_results.should_not be_blank
        boosted_results.length.should == 1
        boosted_results.first["title"].should == "title"
        boosted_results.first["url"].should == "http://example.com"
        boosted_results.first["description"].should == "description"
      end
    end

    describe "jsonp support" do
      it "should wrap response with predefined callback if callback is not blank" do
        affiliate = affiliates(:basic_affiliate)
        search_results = { :spelling_suggestions => "house" }.to_json
        ApiSearch.should_receive(:search).and_return(search_results)
        get :search, :affiliate => affiliate.name, :query => "haus", :callback => 'processData', :format => 'json'
        response.body.should == %{processData({"spelling_suggestions":"house"})}
      end
    end

    context "when it's a news search" do
      fixtures :rss_feeds, :rss_feed_urls, :news_items
      let(:affiliate) { affiliates(:basic_affiliate) }
      let(:feed) { rss_feeds(:white_house_blog) }

      before do
        11.times do |x|
          feed.news_items.create!(
            :link => "http://some.agency.gov/news/1/#{x}",
            :title => "Irrigation News part #{x}",
            :description => "News element part #{x} has a description",
            :published_at => Time.now,
            :guid => "GUID is #{x}",
            :rss_feed_url_id => rss_feed_urls(:white_house_blog_url).id)
        end
        affiliate.sayt_suggestions.create!(:phrase => "related to irrigation")
        NewsItem.reindex
        SaytSuggestion.reindex
        Sunspot.commit
        get :search, :affiliate => affiliate.name, :format => 'json', :query => 'irrigate', :index => 'news', :page => '2', :per_page => '10', :channel => feed.id.to_s, :tbs => 'm'
      end

      describe "response body" do
        subject { JSON.parse(response.body) }
        its(['total']) { should == 11 }
        its(['startrecord']) { should == 11 }
        its(['endrecord']) { should == 11 }
        its(['results']) { should_not be_empty }
        its(['related']) { should_not be_empty }
      end
    end

  end

end
