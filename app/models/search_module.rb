class SearchModule < ActiveRecord::Base
  validates_presence_of :tag, :display_name
  validates_uniqueness_of :tag
end
