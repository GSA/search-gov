
class MedTopicRelated < ActiveRecord::Base
  belongs_to :topic, :class_name => "MedTopic"
  belongs_to :related_topic, :class_name => "MedTopic"
end

