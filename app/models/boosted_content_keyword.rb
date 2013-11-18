class BoostedContentKeyword < ActiveRecord::Base
  validates_presence_of :value
  validates_uniqueness_of :value, :scope => :boosted_content_id
  belongs_to :boosted_content

  class << self
    def grep(boosted_contents_ids, query)
      substring_search_fields = %w(value)
      field_clauses = substring_search_fields.collect { |field| "#{field} LIKE ?" }
      values = Array.new(substring_search_fields.size, "%#{query}%")
      where(boosted_content_id: boosted_contents_ids).where(field_clauses.join(" OR "), *values)
    end
  end

end
