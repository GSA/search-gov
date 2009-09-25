class GroupedQuery < ActiveRecord::Base
  validates_presence_of :query
  validates_uniqueness_of :query
  has_and_belongs_to_many :query_groups

  def self.grouped_queries_hash
    all(:include=> :query_groups).inject({}) do |result, element|
      result[element.query] = element
      result
    end
  end

  def to_label
    query
  end
end
