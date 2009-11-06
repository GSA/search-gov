class AffiliatesController < ApplicationController
  sortable_table Affiliate, :display_columns => ['name', 'contact_email', 'contact_name'], :default_sort => ['name', 'ASC'], :per_page => 500

  def index
    get_sorted_objects(params)
  end
end
