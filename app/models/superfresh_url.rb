class SuperfreshUrl < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :url
  
  MSNBOT_USER_AGENT = "msnbot-UDiscovery/2.0b (+http://search.msn.com/msnbot.htm)"
  
  class << self
    def uncrawled_urls(number_of_urls = nil, affiliate = nil)
      sql_options = {}
      sql_options.merge!(:limit => number_of_urls) if number_of_urls
      if affiliate
        find_all_by_crawled_at_and_affiliate_id(nil, affiliate.id, sql_options.merge(:order => 'created_at asc'))
      else
        find_all_by_crawled_at(nil, sql_options.merge(:order => 'created_at asc'))
      end
    end
    
    def crawled_urls(affiliate = nil, page = 1)
      if affiliate
        paginate_by_affiliate_id(affiliate.id, :conditions => ['NOT ISNULL(crawled_at)'], :page => page, :order => 'crawled_at desc')
      end
    end
    
    def process_file(file, affiliate = nil)
      counter = 0
      if file.lines.count <= 100
        file.open
        file.each do |line|
          if SuperfreshUrl.create(:url => line.chomp, :affiliate => affiliate)
            counter += 1
          end
        end
        return counter
      else
        raise 'Too many URLs in your file.  Please limit your file to 100 URLs.'
      end
    end
    
  end
  
end
