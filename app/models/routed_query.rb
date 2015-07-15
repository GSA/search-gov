class RoutedQuery < ActiveRecord::Base
  include ActiveRecordExtension
  include Dupable

  attr_accessible :url, :description, :routed_query_keywords_attributes
  belongs_to :affiliate
  has_many :routed_query_keywords, dependent: :destroy

  validates :description, presence: true
  validates_uniqueness_of :description, scope: :affiliate_id

  validates :affiliate, presence: true
  validates_format_of :url, with: URI.regexp

  validate :keywords_cannot_be_blank

  # https://github.com/rails/rails/issues/4568
  validate :keywords_cannot_be_duplicated

  accepts_nested_attributes_for :routed_query_keywords, allow_destroy: true, reject_if: ->(k) { k['keyword'].blank? }

  def destroy_and_update_attributes(params)
    destroy_on_blank(params[:routed_query_keywords_attributes], :keyword)
    update_attributes(params)
  end

  def keywords_cannot_be_blank
    errors.add(:base, 'Routed query must have 1 or more search terms') if routed_query_keywords.blank? || routed_query_keywords.all?(&:marked_for_destruction?)
  end

  def keywords_cannot_be_duplicated
    return if (dk = duplicated_keywords).empty?
    errors.add(:routed_query_keywords, "The following #{dk.count == 1 ? 'keyword has' : 'keywords have'} been duplicated: #{dk.map { |k| "'#{k}'" }.join(', ')}. Each keyword is case-insensitive and should be added only once.")
  end

  def duplicated_keywords
    routed_query_keywords.each(&:valid?) # Normalize keywords via validation
    kw = routed_query_keywords.map(&:keyword).compact.sort
    kw.select { |k| kw.count(k) > 1 }.uniq
  end

  def label
    [url, description].join(': ')
  end
end
