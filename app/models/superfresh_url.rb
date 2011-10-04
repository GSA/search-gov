class SuperfreshUrl < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :url
  validates_format_of :url, :with => /(^$)|(^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?([\/].*)?$)/ix
  before_save :validate_belongs_to_site_domain

  MSNBOT_USER_AGENT = "msnbot-UDiscovery/2.0b (+http://search.msn.com/msnbot.htm)"
  MAX_URLS_PER_FILE_UPLOAD = 100

  class << self
    def uncrawled_urls(number_of_urls = nil, affiliate = nil)
      sql_options = {:order => 'created_at asc'}
      sql_options.merge!(:limit => number_of_urls) if number_of_urls
      affiliate ? find_all_by_crawled_at_and_affiliate_id(nil, affiliate.id, sql_options) : find_all_by_crawled_at(nil, sql_options)
    end

    def crawled_urls(affiliate = nil, page = 1)
      if affiliate
        paginate(:conditions => ['affiliate_id = ? AND NOT ISNULL(crawled_at)', affiliate.id], :page => page, :order => 'crawled_at desc')
      end
    end

    def process_file(file, affiliate = nil, max_urls = MAX_URLS_PER_FILE_UPLOAD)
      counter = 0
      if file.tempfile.lines.count <= max_urls and file.tempfile.open
        file.tempfile.each { |line| counter += 1 if create(:url => line.chomp.strip, :affiliate => affiliate).errors.empty? }
        return counter
      else
        raise "Too many URLs in your file.  Please limit your file to #{max_urls} URLs."
      end
    end
  end

  protected
  def validate_belongs_to_site_domain
    if self.affiliate.nil? or self.affiliate.domains.nil? or self.affiliate.domains.split.detect { |domain| self.url.include?(domain) }
      return true
    else
      self.errors.add(:url, "must refer to one of your site domains.")
      return false
    end
  end
end
