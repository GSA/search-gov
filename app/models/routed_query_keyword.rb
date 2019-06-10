class RoutedQueryKeyword < ActiveRecord::Base
  include Dupable

  before_validation do |record|
    AttributeProcessor.squish_attributes record,
                                         :keyword,
                                         assign_nil_on_blank: true
    record.keyword.downcase! if record.keyword.present?
  end

  belongs_to :routed_query, inverse_of: :routed_query_keywords
  validates :routed_query, presence: true

  validates_presence_of :keyword
  validates_uniqueness_of :keyword, scope: :routed_query_id, case_sensitive: false

  validate :keyword_unique_to_affiliate

  def self.do_not_dup_attributes
    @@do_not_dup_attributes ||= %w(routed_query_id).freeze
  end

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
