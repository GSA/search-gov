class AgencyQuery < ApplicationRecord
  validates_presence_of :phrase, :agency_id
  validates_uniqueness_of :phrase, :case_sensitive => false
  belongs_to :agency
end
