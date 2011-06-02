class AgencyUrl < ActiveRecord::Base
  validates_presence_of :agency_id, :url, :locale
  validates_uniqueness_of :url, :scope => :locale
  belongs_to :agency
end
