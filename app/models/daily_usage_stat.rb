class DailyUsageStat < ActiveRecord::Base
  validates_presence_of :day, :profile, :affiliate
  validates_uniqueness_of :day, :scope => [:profile, :affiliate]

  WEBTRENDS_HOSTNAME = 'ws.webtrends.com'
  WEBTRENDS_ACCOUNT = 'usa.gov'
  WEBTRENDS_USERNAME = 'Jay Virdy'
  WEBTRENDS_PASSWORD = 'S3@rch.USA.gov'

  PROFILE_NAMES = [ "English", "Spanish", "Affiliates" ]
  PROFILES = { "English" => { :name => "Search English", :profile_id => "TAaTt56X0j6" },
               "Spanish" => { :name => "Search Spanish", :profile_id => "I2JrcxgX0j6" },
               "Affiliates" => { :name => "Search Affiliates", :profile_id => "ivO5EkIX0j6" }
  }

  def self.monthly_totals(year, month, affiliate_name = 'usasearch.gov')
    result = {}
    if affiliate_name != 'usasearch.gov'
      profile_totals = {}
      profile_totals[:total_queries] = total_monthly_queries(year, month, 'Affiliates', affiliate_name)
      result[affiliate_name] = profile_totals
    else
      PROFILE_NAMES.each do |profile|
        profile_totals = {}
        profile_totals[:total_queries] = total_monthly_queries(year, month, profile, affiliate_name)
        profile_totals[:total_page_views] = total_monthly_page_views(year, month, profile, affiliate_name)
        profile_totals[:total_unique_visitors] = total_monthly_unique_visitors(year, month, profile, affiliate_name)
        result[profile] = profile_totals
      end
    end
    return result
  end

  def self.total_monthly_queries(year, month, profile, affiliate)
    sum_usage_stat_by_month(:total_queries, year, month, profile, affiliate)
  end

  def self.total_monthly_page_views(year, month, profile, affiliate)
    sum_usage_stat_by_month(:total_page_views, year, month, profile, affiliate)
  end

  def self.total_monthly_unique_visitors(year, month, profile, affiliate)
    sum_usage_stat_by_month(:total_unique_visitors, year, month, profile, affiliate)
  end

  def self.sum_usage_stat_by_month(field, year, month, profile, affiliate)
    report_date = Date.civil(year, month)
    DailyUsageStat.sum(field, :conditions => [ "(day between ? and ?) AND profile = ? AND affiliate = ?", report_date.beginning_of_month, report_date.end_of_month, profile, affiliate ])
  end

  def self.update_webtrends_stats_for(day)
    PROFILES.each_key do |profile_name|
      daily_usage_stat = find_or_initialize_by_day_and_profile_and_affiliate(day, profile_name, Affiliate::USAGOV_AFFILIATE_NAME)
      daily_usage_stat.populate_webtrends_data
      daily_usage_stat.save!
    end
  end

  def populate_webtrends_data
    profile_data = JSON.parse(get_profile_data)
    query_date = self.day.strftime('%m/%d/%Y')
    self.total_page_views = profile_data["data"][query_date]["measures"]["Page Views"]
    self.total_unique_visitors = profile_data["data"][query_date]["measures"]["Visitors"]
  end

  def get_profile_data
    Net::HTTP.new(WEBTRENDS_HOSTNAME, Net::HTTP.http_default_port).start do |http|
      request = Net::HTTP::Get.new("/v2/ReportService/profiles/#{PROFILES[self.profile][:profile_id]}/?period=#{self.day.strftime('%Ym%md%d')}&format=json")
      request.basic_auth "#{WEBTRENDS_ACCOUNT}\\#{WEBTRENDS_USERNAME}", WEBTRENDS_PASSWORD
      response = http.request(request)
      case response
        when Net::HTTPSuccess, Net::HTTPRedirection
          response.body
        else
          response.error!
      end
    end
  end

end
