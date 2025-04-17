class Filter < ApplicationRecord
  belongs_to :filter_setting

  before_validation :set_default_label, if: -> { label.blank? && enabled }

  validates :label, presence: true, if: :enabled?
  validate :must_customize_custom_filter

  private

  def set_default_label
    self.label = type.presence
  end

  def must_customize_custom_filter
    return if label.nil?

    if label.match?(/Custom[1-3]/) && enabled && label == "Custom#{label[-1]}"
      errors.add(:label, 'You must customize the label for this custom filter.')
    end
  end
end
