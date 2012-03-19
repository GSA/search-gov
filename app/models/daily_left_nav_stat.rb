class DailyLeftNavStat < ActiveRecord::Base
  validates_presence_of :affiliate_id, :day, :search_type, :total
  belongs_to :affiliate
  EVERYTHING = "Everything"
  ALL_TIME = "All Time"

  class << self
    def collect_to_json(affiliate, start_date, end_date)
      return nil if end_date.nil? or start_date.nil? or affiliate.nil?
      web_hash, image_hash, docs_hash, news_hash = {}, {}, {}, {}
      sum(:total,
          :conditions => ['day between ? AND ? AND affiliate_id = ?', start_date, end_date, affiliate.id],
          :group => [:search_type, :params],
          :order => 'sum_total desc').each do |res|
        search_type, params = res.first
        total = res.last
        case search_type
          when '/search/images'
            image_hash = {:label => "Images: #{total}"}
          when '/search/docs'
            document_collection_name = affiliate.document_collections.find(params).name rescue EVERYTHING
            docs_hash[:label] ||= "Docs"
            docs_hash[:children] ||= []
            docs_hash[:children] << {:label => "#{document_collection_name}: #{total}"}
          when '/search/news'
            channel_id, tbs = params.split ':'
            channel_name = channel_id == "NULL" ? EVERYTHING : affiliate.rss_feeds.find(channel_id).name rescue next
            timeframe = NewsItem::TIME_BASED_SEARCH_OPTIONS[tbs]
            tbs_label = timeframe ? "Last #{timeframe.to_s.capitalize}" : ALL_TIME
            news_hash[:label] ||= "News"
            news_hash[:children] ||= []
            news_hash[:children] << {:label => channel_name, :children => []} unless news_hash[:children].find { |h| h[:label] == channel_name }
            channel_hash = news_hash[:children].find { |h| h[:label] == channel_name }
            channel_hash[:children] << {:label => "#{tbs_label}: #{total}"}
          else
            web_hash = {:label => "Web: #{total}"}
        end
      end
      ary = []
      ary << web_hash.to_json unless web_hash.empty?
      ary << image_hash.to_json unless image_hash.empty?
      ary << docs_hash.to_json unless docs_hash.empty?
      ary << news_hash.to_json unless news_hash.empty?
      ary.join ','
    end

    def most_recent_populated_date(affiliate)
      maximum(:day, :conditions => ['affiliate_id = ?', affiliate.id])
    end

    def least_recent_populated_date(affiliate)
      minimum(:day, :conditions => ['affiliate_id = ?', affiliate.id])
    end

    def available_dates_range(affiliate)
      if (lrpd = least_recent_populated_date(affiliate))
        lrpd..most_recent_populated_date(affiliate)
      else
        Date.yesterday..Date.yesterday
      end
    end

    def bulk_load(file_path, day_str)
      day = Date.parse day_str
      File.open(file_path).each do |line|
        affiliate_name, path, dc, channel, tbs, total = line.chomp.split("\001")
        params = nil
        channel = "NULL" if channel == '\N'
        tbs = "NULL" if tbs == '\N'
        if path == '/search/news'
          params = [channel, tbs].join(':')
        elsif path == '/search/docs'
          params = dc
        end
        Affiliate.find_by_name(affiliate_name).daily_left_nav_stats.create(:day => day, :search_type => path, :params => params, :total => total) rescue next
      end
    end
  end
end
