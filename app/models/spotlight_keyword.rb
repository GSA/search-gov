class SpotlightKeyword < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  belongs_to :spotlight

  after_save :reindex_spotlight
  after_destroy :reindex_spotlight

  private
  def reindex_spotlight
    Spotlight.reindex
  end
end
