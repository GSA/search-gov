class RelatedQuery < ActiveRecord::Base
  validates_presence_of :query, :related_query, :score
  validates_numericality_of :score

  before_save :normalize
  
  def self.search_for(query)
    RelatedQuery.find_all_by_query(query.downcase, :order => "score desc", :limit => 5)
  end
  
  def self.load_json(filename)
    File.open(filename) do |file|
      while line = file.gets
        line_parts = line.split("\t")
        query = line_parts.first
        json = line_parts.last
        parsed_json = JSON.parse(json)
        parsed_json.each do |fake_query, related_queries|
          related_queries.each do |related_query, score|
            RelatedQuery.create(:query => query, :related_query => related_query, :score => score)
          end
        end
      end
    end
  end
  
  private
  
  def normalize
    self.query = self.query.downcase
    self.related_query = self.related_query.downcase
  end
end
