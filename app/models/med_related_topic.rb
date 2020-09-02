class MedRelatedTopic < ApplicationRecord
  validates_presence_of :related_medline_tid, :title, :url
  belongs_to :med_topic
end
