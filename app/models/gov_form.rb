class GovForm < ActiveRecord::Base
  validates_presence_of :name, :form_number, :agency, :description, :url
  
  # TODO: weight the form_number field so that matches to that rank higher.
  searchable do
    text :name, :form_number
  end

  def self.search_for(query, page = 1, per_page = 3)
    GovForm.search do
      keywords query do
        highlight :name, { :fragment_size => 255, :max_snippets => 1, :merge_continuous_fragments => true }
        highlight :form_number, { :fragment_size => 255, :max_snippets => 1, :merge_continuous_fragments => true }
      end
      paginate :page => page, :per_page => per_page
    end rescue nil
  end
end
