class RoutedQueryKeyword < ActiveRecord::Base
  extend AttributeSquisher

  before_validation_squish :keyword, assign_nil_on_blank: true

  attr_accessible :keyword
  belongs_to :routed_query
  validates :routed_query, presence: true

  validates_presence_of :keyword
  validates_uniqueness_of :keyword, scope: :routed_query_id

  def label
    self.keyword
  end

end
