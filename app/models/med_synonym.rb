class MedSynonym < ApplicationRecord
  validates_presence_of :medline_title, :topic
  belongs_to :topic, class_name: 'MedTopic', inverse_of: :synonyms
end
