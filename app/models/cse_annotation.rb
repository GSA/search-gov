class CseAnnotation < ActiveRecord::Base
  LABEL = "_cse_#{GoogleSearch::SEARCH_CX.split(':').last}"
  validates_presence_of :url
  validates_uniqueness_of :url, :case_sensitive => false
end
