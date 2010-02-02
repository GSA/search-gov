class Faq < ActiveRecord::Base
  validates_presence_of :url, :question, :answer, :ranking
  validates_numericality_of :ranking, :only_integer => true
  
  searchable do
    text :question, :answer
    integer :ranking
  end
  
  def self.search_for(query)
    Faq.search do
      keywords query, :highlight=>false
      paginate :page => 1, :per_page => 3
    end rescue nil
  end
  
end
