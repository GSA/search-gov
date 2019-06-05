class SuggestionBlock < ApplicationRecord
  validates_presence_of :query
  validates_uniqueness_of :query, :case_sensitive => false
end
