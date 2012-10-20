require 'spec_helper'

describe QueriesClicksStat do
  fixtures :queries_clicks_stats, :affiliates
  before(:each) do
    @valid_attributes = {
      :affiliate => Affiliate::USAGOV_AFFILIATE_NAME,
      :query => "government",
      :day => "20090830",
      :url => "http://www.gov.gov/somepage.php?doc_id=9",
      :times => 14
    }
  end

  describe 'validations on create' do
    it { should validate_presence_of :day }
    it { should validate_presence_of :query }
    it { should validate_presence_of :times }
    it { should validate_presence_of :affiliate }
    it { should validate_presence_of :url }
    it { should validate_uniqueness_of(:url).scoped_to([:affiliate, :query, :day]) }

    it "should create a new instance given valid attributes" do
      QueriesClicksStat.create!(@valid_attributes)
    end
  end

  describe ".top_urls(affiliate_name, query, start_date, end_date)" do
    it "should return the most popular clicked URLs for a query on an affiliate over some date range" do
      query, start_date, end_date, affiliate_name = "my query", Date.yesterday, Date.current, "foo"
      QueriesClicksStat.should_receive(:sum).with(:times, :group => :url, :order => "sum_times desc",
                                                  :conditions => ['day between ? AND ? AND affiliate = ? and query = ?',
                                                                  start_date, end_date, affiliate_name, query])

      QueriesClicksStat.top_urls(affiliate_name, query, start_date, end_date)
    end
  end

  describe ".top_queries(affiliate_name, url, start_date, end_date)" do
    it "should return the most popular queries leading to clicks on an affiliate's URL over some date range" do
      url, start_date, end_date, affiliate_name = "http://someurl.gov/foo", Date.yesterday, Date.current, "foo"
      QueriesClicksStat.should_receive(:sum).with(:times, :group => :query, :order => "sum_times desc",
                                                  :conditions => ['day between ? AND ? AND affiliate = ? and url = ?',
                                                                  start_date, end_date, affiliate_name, url])

      QueriesClicksStat.top_queries(affiliate_name, url, start_date, end_date)
    end
  end
end