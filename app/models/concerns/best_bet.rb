module BestBet
  extend ActiveSupport::Concern
  include Dupable

  STATUSES = %w( active inactive ).freeze
  STATUS_OPTIONS = STATUSES.map { |status| [status.humanize, status] }.freeze

  STATUSES.each do |status|
    define_method "is_#{status}?" do
      self.status == status
    end
  end

  included do
    validates_inclusion_of :status, in: STATUSES, message: 'must be selected'
    validate :publish_start_and_end_dates
  end

  def active_and_searchable?
    if publish_end_on
      is_active? && (publish_start_on..publish_end_on).include?(Date.current)
    else
      is_active? && (Date.current >= publish_start_on)
    end
  end

  def display_status
    status.humanize
  end

  def match_keyword_values_only_requires_keywords(keywords_collection)
    if keywords_collection.reject(&:marked_for_destruction?).blank? && match_keyword_values_only?
      self.errors.add(:match_keyword_values_only, 'requires at least one keyword')
    end
  end

  private

  def publish_start_and_end_dates
    start_date = publish_start_on.present? ? publish_start_on.to_s.to_date : nil
    end_date = publish_end_on.present? ? publish_end_on.to_s.to_date : nil
    if start_date.present? and end_date.present? and start_date > end_date
      errors.add(:base, "Publish end date can't be before publish start date")
    end
  end
end
