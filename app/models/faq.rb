class Faq < ActiveRecord::Base
  validates_presence_of :url, :question, :answer, :ranking, :locale
  validates_numericality_of :ranking, :only_integer => true
  
  searchable do
    text :question
    integer :ranking
    string :locale
  end
  
  class << self
    
    def search_for(query, locale = I18n.default_locale.to_s, per_page = 3)
      Faq.search do
        fulltext query do
          highlight :question, { :fragment_size => 255, :max_snippets => 1, :merge_continuous_fragments => true }
        end
        with(:locale).equal_to(locale)
        paginate :page => 1, :per_page => per_page
      end rescue nil
    end
    
  end
    
end
