class MedGroup < ActiveRecord::Base

  validates_presence_of :medline_title, :medline_gid, :locale

  has_many :topic_relaters, :class_name => "MedTopicGroup", :foreign_key => :group_id, :dependent => :destroy
  has_many :related_topics, :through => :topic_relaters, :source => :topic

  class << self 
  end

end

