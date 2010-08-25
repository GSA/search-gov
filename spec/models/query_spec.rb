require "#{File.dirname(__FILE__)}/../spec_helper"
describe Query do
  before(:each) do
    @valid_attributes = {
      :query => "government",
      :ipaddr => "123.456.7.89",
      :affiliate => "usasearch.gov",
      :timestamp => Time.now,
      :locale => "en"
    }
  end

  it "should create a new instance given valid attributes" do
    Query.create!(@valid_attributes)
  end
  
  it "should set the is_contextual value to false" do
    Query.create!(@valid_attributes).is_contextual.should be_false
  end

  should_validate_presence_of :ipaddr
  should_validate_presence_of :affiliate
  should_validate_presence_of :timestamp
  should_validate_presence_of :locale
  
  describe "#top_queries" do
    it "should query between the start and end times specified, using 'en' as the default locale, 'usasearch.gov' as the default affiliate, limit of 30K and excluding bots and contextual queries" do
      @date = Date.parse('20100603')
      Query.should_receive(:find).with(:all, :select => "DISTINCT query, count(*) AS total", :conditions => ["timestamp BETWEEN ? AND ? AND affiliate=? AND locale=? AND query NOT IN (?) AND ipaddr NOT IN (?) AND is_contextual=false #{ Query::EXCLUDE_BOTS_CLAUSE }", @date.beginning_of_month.beginning_of_day, @date.end_of_month.end_of_day, 'usasearch.gov', 'en', Query::DEFAULT_EXCLUDED_QUERIES, Query::DEFAULT_EXCLUDED_IPADDRESSES], :joins => 'FORCE INDEX (timestamp)', :group => 'query', :order => 'total desc', :limit => 30000).and_return []
      Query.top_queries(@date.beginning_of_month.beginning_of_day, @date.end_of_month.end_of_day)
    end
    
    it "should use specified values for locale, affiliate, limit and excluding bots when specified" do
      @date = Date.parse('20100603')
      Query.should_receive(:find).with(:all, :select => "DISTINCT query, count(*) AS total", :conditions => ["timestamp BETWEEN ? AND ? AND affiliate=? AND locale=? AND query NOT IN (?) AND ipaddr NOT IN (?) AND is_contextual=false ", @date.beginning_of_month.beginning_of_day, @date.end_of_month.end_of_day, 'affiliate.gov', 'es', Query::DEFAULT_EXCLUDED_QUERIES, Query::DEFAULT_EXCLUDED_IPADDRESSES], :joins => 'FORCE INDEX (timestamp)', :group => 'query', :order => 'total desc', :limit => 4000).and_return []
      Query.top_queries(@date.beginning_of_month.beginning_of_day, @date.end_of_month.end_of_day, 'es', 'affiliate.gov', 4000, false)
    end
  end

end
