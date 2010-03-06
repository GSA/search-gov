class AffiliateTemplate < ActiveRecord::Base
  has_many :affiliates
  validates_presence_of :name, :stylesheet
  validates_uniqueness_of :stylesheet
  
  class << self
    def default
      first
    end
  end
end
