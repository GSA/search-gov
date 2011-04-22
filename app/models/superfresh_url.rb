class SuperfreshUrl < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :url
  validates_format_of :url, :with=> /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.(gov|mil)(:[0-9]{1,5})?(\/.*)?$/ix

  MSNBOT_USER_AGENT = "msnbot-UDiscovery/2.0b (+http://search.msn.com/msnbot.htm)"
  MAX_URLS_PER_FILE_UPLOAD = 100

  class << self
    def uncrawled_urls(number_of_urls = nil, affiliate = nil)
      sql_options = {:order => 'created_at asc'}
      sql_options.merge!(:limit => number_of_urls) if number_of_urls
      affiliate ? find_all_by_crawled_at_and_affiliate_id(nil, affiliate.id, sql_options) : find_all_by_crawled_at(nil, sql_options)
    end

    def crawled_urls(affiliate = nil, page = 1)
      paginate_by_affiliate_id(affiliate.id, :conditions => ['NOT ISNULL(crawled_at)'], :page => page, :order => 'crawled_at desc') if affiliate
    end

    def process_file(file, affiliate = nil)
      counter = 0
      if file.lines.count <= MAX_URLS_PER_FILE_UPLOAD
        file.open
        file.each do |line|
          if create(:url => line.chomp, :affiliate => affiliate)
            counter += 1
          end
        end
        return counter
      else
        raise "Too many URLs in your file.  Please limit your file to #{MAX_URLS_PER_FILE_UPLOAD} URLs."
      end
    end
  end
end
