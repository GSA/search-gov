class FilterSetting < ApplicationRecord
  belongs_to :affiliate
  has_one :topic, class_name: 'Filter'
  has_one :file_type, class_name: 'Filter'
  has_one :content_type, class_name: 'Filter'
  has_one :audience, class_name: 'Filter'
  has_one :date, class_name: 'Filter'

  has_one :custom_1, class_name: 'CustomFilter'
  has_one :custom_2, class_name: 'CustomFilter'
  has_one :custom_3, class_name: 'CustomFilter'
end