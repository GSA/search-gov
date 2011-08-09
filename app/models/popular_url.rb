class PopularUrl < ActiveRecord::Base
  validates_presence_of :title, :url, :rank
  validates_uniqueness_of :url, :scope => :affiliate_id
  belongs_to :affiliate
  scope :sorted, order("rank desc")
  scope :top, lambda { |l| limit(l) }

  def self.top_urls(limit = 3)
    sorted.top(limit)
  end
end
