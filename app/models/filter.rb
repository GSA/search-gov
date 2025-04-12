class Filter < ApplicationRecord
  belongs_to :filter_setting

  validates :label, presence: true
  validate :must_customize_custom_filter
  validates :label, presence: true, if: :enabled?

  private

  def must_customize_custom_filter
    return if label.nil?

    if label.match?(/Custom[1-3]/) && enabled && label == "Custom#{label[-1]}"
      errors.add(:label, 'You must customize the label for this custom filter.')
    end
  end
end