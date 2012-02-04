class MedTopicGroup < ActiveRecord::Base
  belongs_to :topic, :class_name => "MedTopic"
  belongs_to :group, :class_name => "MedGroup"
end