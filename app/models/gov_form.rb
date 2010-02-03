class GovForm < ActiveRecord::Base
  validates_presence_of :name, :form_number, :agency, :description, :url
  
  searchable do
    text :name, :form_number, :agency, :bureau, :description
  end

  def self.search_for(query)
    GovForm.search do
      keywords query do
        highlight :name, { :fragment_size => 255, :max_snippets => 1, :merge_continuous_fragments => true }
      end
      paginate :page => 1, :per_page => 3
    end rescue nil
  end
end
