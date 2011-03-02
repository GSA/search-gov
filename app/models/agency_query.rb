class AgencyQuery < ActiveRecord::Base
  validates_presence_of :phrase, :agency_id
  validates_uniqueness_of :phrase
  belongs_to :agency
end
