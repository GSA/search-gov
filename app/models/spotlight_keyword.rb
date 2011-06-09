class SpotlightKeyword < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name
  belongs_to :spotlight

  after_save :index_parent_spotlight
  after_destroy :index_parent_spotlight

  private
  def index_parent_spotlight
    spotlight.index
  end
end
