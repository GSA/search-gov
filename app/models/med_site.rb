class MedSite < ApplicationRecord
  validates_presence_of :title, :url
  belongs_to :med_topic
end
