class Filter < ApplicationRecord
  belongs_to :filter_setting

  acts_as_list scope: :filter_setting

  validates :label, presence: true
  validate :must_customize_custom_filter

  private

  def must_customize_custom_filter
    return if label.nil?

    if label.match?(/Custom[1-3]/) && enabled && label == "Custom#{label[-1]}"
      errors.add(:label, 'You must customize the label for this custom filter.')
    end
  end
end