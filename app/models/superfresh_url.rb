class SuperfreshUrl < ActiveRecord::Base
  belongs_to :affiliate
  validates_presence_of :url
  
  class << self
    def uncrawled_urls(affiliate = nil)
      if affiliate
        find_all_by_crawled_at_and_affiliate_id(nil, affiliate.id, :order => 'created_at asc')
      else
        find_all_by_crawled_at(nil, :order => 'created_at asc')
      end
    end
    
    def crawled_urls(affiliate = nil, page = 1)
      if affiliate
        paginate_by_affiliate_id(affiliate.id, :conditions => ['NOT ISNULL(crawled_at)'], :page => page, :order => 'crawled_at desc')
      end
    end
  end
end
