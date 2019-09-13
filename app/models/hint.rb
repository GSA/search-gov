class Hint < ApplicationRecord
  before_validation do |record|
    AttributeProcessor.squish_attributes record,
                                         :name,
                                         :value,
                                         assign_nil_on_blank: true
  end

  validates_presence_of :name

  def self.name_starts_with(prefix)
    where('name IS NOT NULL AND name LIKE ?', "#{prefix}.%")
  end
end
