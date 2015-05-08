class Hint < ActiveRecord::Base
  extend AttributeSquisher

  attr_accessible :name, :value
  before_validation_squish :name,
                           :value,
                           assign_nil_on_blank: true

  validates_presence_of :name

  def self.name_starts_with(prefix)
    where('name IS NOT NULL AND name LIKE ?', "#{prefix}.%")
  end
end
