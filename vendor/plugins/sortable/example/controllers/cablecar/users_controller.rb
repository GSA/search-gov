module Cablecar
  class UsersController < ActionController::Base

    # By default this will create an index action that uses the default sortable table partial to render the list of objects
    sortable_table Cablecar::User

    # The following index action demonstrates various ways that you can fetch and display your objects in a paginated, sortable,
    # searchable table. Each clause in the elsif chain below could be its own index action on its own but all are included here
    # for demo and testing purposes. Each example is triggered by passing the appropriate param value to trigger the desired
    # clause to demo.
    def index
      if params[:filter_example]
        # This demonstrates the ability to add additional conditions to fetching the list of objects. This will filter
        # the results to the list of active users
        if params[:active]
          conditions = 'cablecar_users.status = "active"'
        end
        get_sorted_objects(params, :conditions => conditions)      
      elsif params[:complex_example]
        # This example demonstrates a more complicated example that displays the flexibility of creating the sortable table.
        # Here we are showing an attribute on a related object as a sortable column in the table, namely the contact_info name
        # column. We're also restricting the visible columns to 3 columns as well as defining the sort order for each column
        # as well as the default sort column. We're also specifying what columns should be used when a search is performed.
        # Finally we're also setting the number of results to show per page.
        get_sorted_objects(params, :include_relations => [:contact_info],
                                   :table_headings => [['Username', 'username'], ['Status', 'status'], ['Name', 'name']],
                                   :sort_map => {:username => [['cablecar_users.username', 'DESC'], 
                                                               ['cablecar_users.status', 'DESC']], 
                                                 :status => ['cablecar_users.status', 'ASC'],
                                                 :name => ['cablecar_contact_infos.name', 'DESC']},
                                   :default_sort => ['name', 'ASC'],
                                   :search_array => ['cablecar_users.username', 'cablecar_contact_infos.name'],
                                   :per_page => 15)      
      elsif params[:no_pagination]
        @hide_pagination = true
        get_sorted_objects(params)      
      else
        if params[:use_default]
          super
        else
          # If you wish to override how the objects are fetched this is the simplest way to do so
          # The key is that you simply need to call get_sorted_objects with your params and any optional overrides for 
          # sortable defaults. See sortable.rb for more details on overrides.
          get_sorted_objects(params)      
        end
      end
    end
  end
end