class RoutedQueryKeyword < ActiveRecord::Base
  extend AttributeSquisher

  before_validation_squish :keyword, assign_nil_on_blank: true

  attr_accessible :keyword

  belongs_to :routed_query
  validates :routed_query, presence: true

  validates :keyword, uniqueness: { scope: :routed_query_id, case_insensitive: true }, presence: true
  before_validation { |record| record.keyword.downcase! if record.keyword.present? }

  validate :keyword_unique_to_affiliate

  def label
    keyword
  end

  def keyword_unique_to_affiliate
    return unless routed_query && routed_query.affiliate

    relation = routed_query.affiliate.routed_queries
               .joins(:routed_query_keywords)
               .where('routed_query_keywords.keyword = ?', keyword)

    relation = relation.where('routed_query_id != ?', routed_query_id) if routed_query_id

    if relation.any?
      errors[:keyword] << "The keyword '#{keyword}' is already in use for a different routed query"
    end
  end
end
