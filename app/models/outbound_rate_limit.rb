class OutboundRateLimit < ActiveRecord::Base
  attr_accessible :limit, :name
  attr_readonly :name
  validates_presence_of :limit, :name
  validates_uniqueness_of :name, case_sensitive: false

  def self.load_defaults
    create!(name: GoogleSearch::NAMESPACE,
            limit: 3000) unless find_by_name(GoogleSearch::NAMESPACE)
  end
end
