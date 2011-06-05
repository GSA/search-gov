class AgencyPopularUrl < ActiveRecord::Base

  validates_presence_of :agency_id, :title, :url
  validates_uniqueness_of :url

  belongs_to :agency

end
