class GroupedQuery < ActiveRecord::Base
  validates_presence_of :query
  validates_uniqueness_of :query
  has_and_belongs_to_many :query_groups

  def to_label
    query
  end
end
