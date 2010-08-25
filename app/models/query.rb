class Query < ActiveRecord::Base
  validates_presence_of :ipaddr
  validates_presence_of :timestamp
  validates_presence_of :affiliate
  validates_presence_of :locale
  
  DEFAULT_EXCLUDED_QUERIES = ['enter keywords', 'cheesewiz' , 'cheeseman', 'clusty' ,' ', '1', 'test']
  DEFAULT_EXCLUDED_IPADDRESSES = ['192.107.175.226', '74.52.58.146' , '208.110.142.80' , '66.231.180.169']
  EXCLUDE_BOTS_CLAUSE = "AND (is_bot=false OR ISNULL(is_bot))"
  
  def self.top_queries(start_time, end_time, locale = 'en', affiliate = 'usasearch.gov', result_count = 30000, exclude_bots = true)
    Query.find(:all, :select => "DISTINCT query, count(*) AS total", :conditions => ["timestamp BETWEEN ? AND ? AND affiliate=? AND locale=? AND query NOT IN (?) AND ipaddr NOT IN (?) AND is_contextual=false #{ exclude_bots ? EXCLUDE_BOTS_CLAUSE : "" }", start_time, end_time, affiliate, locale, DEFAULT_EXCLUDED_QUERIES, DEFAULT_EXCLUDED_IPADDRESSES], :joins => 'FORCE INDEX (timestamp)', :group => 'query', :order => 'total desc', :limit => result_count)
  end
end
