require 'spec/spec_helper'

describe AgencyPopularUrl do
  before do
    Affiliate.destroy_all
  end

  it { should validate_presence_of :agency_id }
  it { should validate_presence_of :url }
  it { should validate_presence_of :title }
  it { should validate_presence_of :source }
  it { should validate_presence_of :locale }

  SUPPORTED_LOCALES.each do |locale|
    it { should allow_value(locale).for(:locale) }
  end
  it { should_not allow_value("invalid_locale").for(:locale) }

  it "should default source to 'admin'" do
    agency = Agency.create!(:name => 'test.gov', :domain => 'test.gov')
    agency_popular_url = AgencyPopularUrl.create!(:url => 'http://test.gov', :title => 'Test', :rank => 12, :agency => agency, :locale => 'en')
    agency_popular_url.source.should == 'admin'
  end

  describe ".with_locale" do
    let(:agency) { Agency.create!(:name => 'test', :domain => 'test.gov') }
    let(:en_agency_popular_url) do
      agency.agency_popular_urls.create!(:title => 'First Blog Post',
                                         :url => 'http://test.gov/en/blog/1',
                                         :rank => 12,
                                         :locale => 'en')
    end

    let(:es_agency_popular_url) do
      agency.agency_popular_urls.create!(:title => 'Primero Blog Post',
                                         :url => 'http://test.gov/es/blog/1',
                                         :rank => 12,
                                         :locale => 'es')
    end
    subject { agency }
    specify { agency.agency_popular_urls.with_locale('en').should == [en_agency_popular_url] }
    specify { agency.agency_popular_urls.with_locale('es').should == [es_agency_popular_url] }
  end

  describe "#compute_for_date" do
    before do
      @bitly_api = mock(BitlyAPI)
      @bitly_api.stub!(:get_popular_links_for_domain).and_return []
      BitlyAPI.should_receive(:new).and_return @bitly_api
    end

    context "when no date is passed" do
      it "should grab the date specified and process the file" do
        @bitly_api.should_receive(:grab_csv_for_date).with(Date.yesterday).and_return "filename"
        @bitly_api.should_receive(:parse_csv).with("filename").and_return true
        AgencyPopularUrl.compute_for_date
      end
    end

    context "when a date is passed" do
      it "should grab the date specified and process the file" do
        date = Date.parse('2011-07-01')
        @bitly_api.should_receive(:grab_csv_for_date).with(date).and_return "filename"
        @bitly_api.should_receive(:parse_csv).with("filename").and_return true
        AgencyPopularUrl.compute_for_date(date)
      end
    end

    context "when popular links are returned" do
      before do
        @bitly_api.stub!(:get_popular_links_for_domain).and_return [{:long_url => 'http://search.usa.gov/search?query=test&amp;locale=en', :clicks => 100, :title => 'Search.USA.gov'}]
        @bitly_api.stub!(:grab_csv_for_date).and_return "filename"
        @bitly_api.stub!(:parse_csv).and_return true
      end

      context "when an agency is present" do
        before do
          Agency.destroy_all
          @agency = Agency.create!(:name => "Usa.gov", :domain => "usa.gov")
          @agency.agency_popular_urls.create!(:url => 'http://test.com', :title => "Test", :rank => 99, :source => 'bitly', :locale => 'en')
          @agency.agency_popular_urls.create!(:url => 'http://test.com/admin', :title => "Test", :rank => 99, :source => 'admin', :locale => 'en')
          @agency.agency_popular_urls.size.should == 2
        end

        it "should delete all the existing agency urls and add in those returned" do
          AgencyPopularUrl.compute_for_date
          @agency.reload
          @agency.agency_popular_urls.size.should == 2
          @agency.agency_popular_urls.last.url.should == "http://search.usa.gov/search?query=test&locale=en"
        end

        context "when the link is already in the list" do
          before do
            @agency.agency_popular_urls.create!(:url => 'http://search.usa.gov/search?query=test&locale=en', :title => "Test", :rank => 99, :source => 'admin', :locale => 'en')
          end

          it "should leave it as is" do
            AgencyPopularUrl.compute_for_date
            @agency.reload
            @agency.agency_popular_urls.size.should == 2
            @agency.agency_popular_urls.last.title.should == "Test"
            @agency.agency_popular_urls.last.rank.should == 99
          end
        end
      end

      context "when an affiliat is present" do
        before do
          @affiliate = Affiliate.create(:display_name => 'USA.gov', :name => 'usa.gov', :search_results_page_title => 'Test', :staged_search_results_page_title => 'Test')
          @affiliate.add_site_domains('usa.gov' => nil, 'search.usa.gov' => nil)
          @affiliate.popular_urls << PopularUrl.new(:url => 'http://test.com', :title => 'Test.com', :rank => 100)
          @affiliate.popular_urls << PopularUrl.new(:url => 'http://test.com/2', :title => 'Test 2', :rank => 99)
        end

        it "should delete all existing popular urls and add in those returned" do
          AgencyPopularUrl.compute_for_date
          @affiliate.reload
          @affiliate.popular_urls.size.should == 1
          @affiliate.popular_urls.first.url.should == "http://search.usa.gov/search?query=test&locale=en"
        end

        context "when the link is already in the list" do
          before do
            @affiliate.popular_urls.create!(:url => 'http://search.usa.gov/search?query=test&locale=en', :title => "Test", :rank => 99)
          end

          it "should update it" do
            AgencyPopularUrl.compute_for_date
            @affiliate.reload
            @affiliate.popular_urls.size.should == 1
            @affiliate.popular_urls.last.title.should == "Search.USA.gov"
            @affiliate.popular_urls.last.url.should == "http://search.usa.gov/search?query=test&locale=en"
            @affiliate.popular_urls.last.rank.should == 100
          end
        end
      end
    end
  end
end