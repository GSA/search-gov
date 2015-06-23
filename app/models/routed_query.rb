class RoutedQuery < ActiveRecord::Base
  include ActiveRecordExtension

  attr_accessible :url, :description, :routed_query_keywords_attributes
  belongs_to :affiliate
  has_many :routed_query_keywords, dependent: :destroy

  validates :description, presence: true
  validates_uniqueness_of :description, scope: :affiliate_id

  validates :affiliate, presence: true
  validates_format_of :url, with: URI.regexp

  validate :keywords_cannot_be_blank

  accepts_nested_attributes_for :routed_query_keywords, allow_destroy: true, reject_if: ->(k) { k['keyword'].blank? }

  def destroy_and_update_attributes(params)
    destroy_on_blank(params[:routed_query_keywords_attributes], :keyword)
    update_attributes(params)
  end

  def keywords_cannot_be_blank
    errors.add(:base, 'Routed query must have 1 or more search terms') if routed_query_keywords.blank? || routed_query_keywords.all?(&:marked_for_destruction?)
  end

  def label
    [url, description].join(': ')
  end
end
