#require 'active_record/validate_unique_child_attribute'

class RoutedQuery < ApplicationRecord
  include Dupable
  include ActiveRecord::ValidateUniqueChildAttribute

  belongs_to :affiliate
  has_many :routed_query_keywords, dependent: :destroy, inverse_of: :routed_query

  validates :description, presence: true
  validates_uniqueness_of :description, scope: :affiliate_id

  validates :affiliate, presence: true
  validates_url :url

  validate :keywords_cannot_be_blank

  validates_uniqueness_of_child_attribute :routed_query_keywords, :keyword,
    validate: true, error_formatter: :duplicate_routed_query_keyword_error_formatter

  accepts_nested_attributes_for :routed_query_keywords, allow_destroy: true, reject_if: ->(k) { k['keyword'].blank? }

  def destroy_and_update_attributes(params)
    destroy_on_blank(params[:routed_query_keywords_attributes], :keyword)
    update(params)
  end

  def keywords_cannot_be_blank
    errors.add(:base, 'Routed query must have 1 or more search terms') if routed_query_keywords.blank? || routed_query_keywords.all?(&:marked_for_destruction?)
  end

  def label
    [url, description].join(': ')
  end

  def duplicate_routed_query_keyword_error_formatter(_, dk)
    "The following #{dk.count == 1 ? 'keyword has' : 'keywords have'} been duplicated: #{dk.map { |k| "'#{k}'" }.join(', ')}. Each keyword is case-insensitive and should be added only once."
  end
end
