class PopularUrl < ActiveRecord::Base
  validates_presence_of :title, :url, :rank
  validates_uniqueness_of :rank, :scope => :affiliate_id
  belongs_to :affiliate
  scope :sorted, order("rank asc")
  scope :top, lambda { |l| limit(l) }

  def self.top_urls(limit = 5)
    sorted.top(limit)
  end
end
