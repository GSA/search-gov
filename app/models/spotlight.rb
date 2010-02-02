class Spotlight < ActiveRecord::Base
  validates_presence_of :title
  validates_uniqueness_of :title
  has_many :spotlight_keywords, :dependent=> :destroy, :order => 'name ASC'

  searchable do
    boolean :is_active
    text :spotlight_keywords do
      spotlight_keywords.map { |spotlight_keyword| spotlight_keyword.name }
    end
  end

  def self.search_for(query)
    solr = Spotlight.search do
      with :is_active, true
      keywords query
      paginate :page => 1, :per_page => 1
    end rescue nil
    solr.results.first unless solr.nil? or solr.results.empty?
  end

end
