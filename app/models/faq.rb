class Faq < ActiveRecord::Base
  validates_presence_of :url, :question, :answer, :ranking
  validates_numericality_of :ranking, :only_integer => true
  
  searchable do
    text :question
    integer :ranking
  end
  
  def self.search_for(query)
    Faq.search do
      keywords query do
        highlight :question, { :fragment_size => 255, :max_snippets => 1, :merge_continuous_fragments => true }
      end
      paginate :page => 1, :per_page => 3
    end rescue nil
  end
  
end
