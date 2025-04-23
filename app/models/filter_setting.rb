class FilterSetting < ApplicationRecord
  belongs_to :affiliate
  has_many :filters, dependent: :destroy
  has_one :topic, class_name: 'Filter'
  has_one :file_type, class_name: 'Filter'
  has_one :content_type, class_name: 'Filter'
  has_one :audience, class_name: 'Filter'
  has_one :date, class_name: 'Filter'

  has_one :custom_1, class_name: 'CustomFilter'
  has_one :custom_2, class_name: 'CustomFilter'
  has_one :custom_3, class_name: 'CustomFilter'

  accepts_nested_attributes_for :filters, allow_destroy: true

  def initialize_default_filters_preview
    generate_default_filters.map.with_index do |(label, subtype), position|
      Filter.new(type: subtype, label: label, position: position, enabled: false)
    end
  end

  private

  def generate_default_filters
    {
      'Topic' => 'TopicFilter',
      'FileType' => 'FileTypeFilter',
      'ContentType' => 'ContentTypeFilter',
      'Audience' => 'AudienceFilter',
      'Date' => 'DateFilter',
      'Custom1' => 'CustomFilter',
      'Custom2' => 'CustomFilter',
      'Custom3' => 'CustomFilter'
    }
  end
end