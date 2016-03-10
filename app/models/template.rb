class Template < ActiveRecord::Base
  DEFAULT_TEMPLATE_TYPE = "Template::Classic"
  
  # The .subclasses method does not work in RAIL_ENV=development
  # unless development.rb has the following set:
  # config.cache_classes = true
  TEMPLATE_SUBCLASSES = ["Template::Classic", "Template::RoundedHeaderLink"]

  attr_accessible :active, :type, :schema
  attr_reader :affiliate_id

  has_one :affiliate
  belongs_to :affiliate


  validates_presence_of :affiliate
  validates :type, presence: true,  if: :valid_template_subclass?
  
  def valid_template_subclass?
    TEMPLATE_SUBCLASSES.include?(type) || raise("Not a valid subclass.")
  end

  validates_uniqueness_of( 
    :affiliate_id, 
    :scope => :type
  )
  
  scope :available, where(active: true)

  # Array of Virtual Classes
  def self.hidden
    hidden_template_types = TEMPLATE_SUBCLASSES - self.available.map(&:type)
    hidden_template_types.map { |template| template.constantize.new }  
  end

  def load_schema
    return Hashie::Mash.new(self.class::DEFAULT_SCHEMA) if self.schema.blank?
    Hashie::Mash.new(JSON.parse(schema))
  end

  def save_schema(mashed_schema)
    merged_hash = (self.class::DEFAULT_SCHEMA).deep_merge(mashed_schema)
    self.update_attribute(:schema, merged_hash.to_json) 
    # return true
  end

  def reset_schema
    self.update_attribute(:schema, self.class::DEFAULT_SCHEMA.to_json)
    return Hashie::Mash.new(JSON.parse(schema))
  end
end
