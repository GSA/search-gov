class AffiliateTemplate < ActiveRecord::Base
  has_many :affiliates
  validates_presence_of :name, :stylesheet
  validates_uniqueness_of :stylesheet

  def self.default_id
    default_template.nil? ? nil : default_template.id
  end

  def self.default_template
    @default_template ||= AffiliateTemplate.find_by_stylesheet("default")
  end
end
