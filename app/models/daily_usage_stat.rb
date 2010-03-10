class DailyUsageStat < ActiveRecord::Base
  validates_presence_of :day, :profile
  validates_uniqueness_of :profile, :scope => :day
    
  WEBTRENDS_HOSTNAME = 'ws.webtrends.com'
  WEBTRENDS_ACCOUNT = 'usa.gov'
  WEBTRENDS_USERNAME = 'Jay Virdy'
  WEBTRENDS_PASSWORD = 'S3@rch.USA.gov'
  
  Profile_Names = [ "English", "Spanish", "Affiliates" ]
  Profiles = { "English" => { :name => "Search English", :profile_id => "TAaTt56X0j6" }, 
               "Spanish" => { :name => "Search Spanish", :profile_id => "I2JrcxgX0j6" },
               "Affiliates" => { :name => "Search Affiliates", :profile_id => "ivO5EkIX0j6" }
             }
             
  def self.monthly_totals(year, month)
    result = {}
    Profile_Names.each do |profile|
      profile_totals = {}
      profile_totals[:total_queries] = total_monthly_queries(year, month, profile)
      profile_totals[:total_page_views] = total_monthly_page_views(year, month, profile)
      profile_totals[:total_unique_visitors] = total_monthly_unique_visitors(year, month, profile)
      profile_totals[:total_clicks] = total_monthly_clicks(year, month, profile)
      result[profile] = profile_totals
    end
    return result
  end
  
  def self.total_monthly_queries(year, month, profile)
    sum_usage_stat_by_month(:total_queries, year, month, profile)
  end
  
  def self.total_monthly_page_views(year, month, profile)
    sum_usage_stat_by_month(:total_page_views, year, month, profile)
  end
  
  def self.total_monthly_unique_visitors(year, month, profile)
    sum_usage_stat_by_month(:total_unique_visitors, year, month, profile)
  end
  
  def self.total_monthly_clicks(year, month, profile)
    sum_usage_stat_by_month(:total_clicks, year, month, profile)
  end
  
  def self.sum_usage_stat_by_month(field, year, month, profile)
    report_date = Date.civil(year, month)
    DailyUsageStat.sum(field, :conditions => [ "(day between ? and ?) AND profile = ?", report_date.beginning_of_month, report_date.end_of_month, profile ])
  end    
  
  def populate_data
    if self.day && self.profile
      self.populate_webtrends_data
      self.populate_queries_data
      self.populate_clicks_data
    end
  end
    
  def populate_webtrends_data
    profile_data = JSON.parse(get_profile_data)
    query_date = "#{self.day.month}/#{self.day.day}/#{self.day.year}"
    self.total_page_views = profile_data["data"][query_date]["measures"]["Page Views"]
    self.total_unique_visitors = profile_data["data"][query_date]["measures"]["Visitors"]
    #self.total_unique_visits = profile_data['data'][query_date]["measures"]["Visits"]
  end
  
  # this will not work, since we don't have profile information available
  # TODO: incorporate profile data here.
  def populate_queries_data
    if self.profile != 'Affiliates'
      locale = self.profile == 'English' ? 'en' : 'es'
      self.total_queries = Query.count(:all, :conditions => ["timestamp between ? and ? AND locale=? AND affiliate=?", Time.parse('00:00', self.day), Time.parse('23:59', self.day), locale, "usasearch.gov"])
    else
      self.total_queries = Query.count(:all, :conditions => ["timestamp between ? and ? AND affiliate <> ?", Time.parse('00:00', self.day), Time.parse('23:59', self.day), "usasearch.gov"])
    end
  end
  
  def populate_clicks_data
  end

  def get_profile_data
    http =  Net::HTTP.new(WEBTRENDS_HOSTNAME, Net::HTTP.http_default_port)
    response = http.start { |http|
      request = Net::HTTP::Get.new("/v2/ReportService/profiles/#{Profiles[self.profile][:profile_id]}/?period=#{self.day.strftime('%Ym%md%d')}&format=json")
      request.basic_auth "#{WEBTRENDS_ACCOUNT}\\#{WEBTRENDS_USERNAME}", WEBTRENDS_PASSWORD
      response = http.request(request)
      case response
        when Net::HTTPSuccess, Net::HTTPRedirection
          return  response.body
        else
          response.error!
        end
    }
  end
  
end
