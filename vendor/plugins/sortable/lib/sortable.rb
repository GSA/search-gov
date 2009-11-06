require 'generator'

module Sortable
    def self.included(base)
      base.extend(ClassMethods)
    end

    module ClassMethods
      # Class method to setup a controller to create a sortable table. 
      #
      # usage: sortable_table class_to_tabularize, optional_params
      # 
      # simplest example possible: 
      # 
      # In your controller...
      # 
      # sortable_table User
      # 
      # This will create a sortable table over all your objects and display all columns.
      # The simplest way to trim down the columns to display is to pass in a parameter specifying which columns
      # on your object you'd like to display:
      #
      # sortable_table User, :display_columns => ['id', 'email', 'name', 'state', 'created_at']
      #
      # This will show the same sortable, searchable, paginated table with only these columns
      # 
      # If you need a bit more control over how the objects are fetchd and displayed this is
      # the next simplest example:
      #
      # Override the index action in your controller:
      #
      # def index
      #  get_sorted_objects(params)        
      # end
      # 
      # In your index action template (within the same controller) put in a helper call to show a sortable table. You can
      # create your own table partial to be used to display the objects. See the sortable/views/sortable/_table.html.erb 
      # (which is the default template used by the plugin) for an example. 
      # 
      # <%= sortable_table %>
      # 
      # The view method will automatically generate a paginated, sortable table for the class type declared in the controller
      # 
      # optional_params:
      # 
      # :per_page - Number of records to show per page. Default is 10
      #
      # The next section deals with how to change what's displayed in the table. The first and simplest option is :display_columns.
      # The more flexible option is to use :table_headings and :sort_map. First we'll go over the simpler option.
      #
      # :display_columns - Specifies which columns that you'd like to display in the table. 
      #
      # For more flexibility you can use :table_headings and :sort_map. You would most likely use this when you want to display 
      # attributes from more than one object in the same table or if you need more flexibility with regards to sort rules. 
      # :table_headings - The table heading label and sort key. Default is all the column names for the given class
      # :sort_map - The mapping between the sort key and the table.column to sort on. Default is all the columns for the given class
      # :include_relations - Relations to include if you choose to display a column in a related object's table
      #
      # :default_sort - The default sorting column and direction when displaying the table without any sort params. Default is 'id DESC'
      # 
      # Note: You *must* override both :table_headings and :sort_map if you do choose to override so that 
      # the contents of the column headings match up with the contents of the sort_map they associate with.
      # Also if you override :default_sort you'll need to change the :table_headings and :sort_map if the new :default_sort
      # column doesn't currently reside within the :table_heading and :sort_map collections
      # 
      # Example of modifying :table_headings or :sort_map :
      #   :table_headings => [['Name', 'name'], ['Status', 'status']]
      #   :sort_map =>  {'name' => ['users.name'], 
      #                  'status' => ['users.status']}
      # 
      #   Note that both 'name' and 'status' are sort keys that map to both the table heading label and the 
      #   database table.column combination that the heading refers to. 
      #   
      #   Also note that :default_sort now needs to change as well since the table no longer contains the :default_sort
      #   column of 'id':
      #   
      #   :default_sort => ['name', 'DESC'] 
      #   
      # Example of modifying :table_headings to include a column from a related object:
      #   :table_headings => [['Name', 'name'], ['Status', 'status'], ['Role', 'role']]
      #   :sort_map =>  {'name' => ['users.name'], 
      #                  'status' => ['users.status'],
      #                  'role' => ['roles.role']}
      #   
      #   Note that we've now added 'roles.role' to the list of columns to display and sort on. In order to
      #   make the find work properly we also need to include the related object, so we pass in the following param:
      #   :include_relations => [:role]
      #   
      #   Perhaps we want to sort by role ascending by default as well. We'd pass the param value:
      #   :default_sort => ['role', 'ASC']               
      #   
      #   and the table is now sortable by a related object's column and is the default sort value for the table.
      #
      # Search. You can specify what columns are searchable on your objects as follows:
      #   :search_array => ['cablecar_users.username', 'cablecar_users.name']
      # 
      # Now search queries will only search username and name for users. By default search is enabled for all columns
      # that are being displayed in the table. This allows you to expand or constrain those values.
      #
      def sortable_table(klass, options={})
        @@sortable_table_options ||={}

        sort_map = HashWithIndifferentAccess.new

        if options[:table_headings] &&
           options[:sort_map]
           table_headings = options[:table_headings]
           sort_map.merge!(options[:sort_map])           
        else
          display_columns = options[:display_columns].blank? ? klass.column_names : options[:display_columns]
          table_headings = []
          klass.column_names.each do |att|
            if display_columns.include?(att)
              table_headings << [att.humanize, att]
              sort_map[att] = ["#{klass.table_name}.#{att}", 'DESC']
            end
          end           
        end

        default_sort = options[:default_sort].nil? ? ['id', 'DESC'] : options[:default_sort]
        per_page = options[:per_page].nil? ? 10 : options[:per_page]
        include_relations = options[:include_relations].nil? ? [] : options[:include_relations]        

        search_array = options[:search_array].nil? ? sort_map.values.collect {|v| v[0]} : options[:search_array]

        @@sortable_table_options[controller_name] = {:class => klass,
                                                     :table_headings => table_headings,
                                                     :default_sort => default_sort,
                                                     :sort_map => sort_map,
                                                     :search_array => search_array,
                                                     :per_page => per_page,
                                                     :include_relations => include_relations}
        
        module_eval do
          include Sortable::InstanceMethods
          def sortable_class
            @@sortable_table_options[controller_name][:class]
          end

          def sortable_table_headings
            @@sortable_table_options[controller_name][:table_headings]
          end
          
          def sortable_default_sort
            @@sortable_table_options[controller_name][:default_sort]
          end
          
          def sortable_sort_map
            @@sortable_table_options[controller_name][:sort_map]
          end
          
          def sortable_search_array
            @@sortable_table_options[controller_name][:search_array]
          end
          
          def sortable_per_page
            @@sortable_table_options[controller_name][:per_page]
          end
          
          def sortable_include_relations
            @@sortable_table_options[controller_name][:include_relations]
          end
        end
    end
      
    end
    
    module InstanceMethods      
      # default impl for listing a collection of objects. Override this action in your controller to fetch objects
      # differently and/or to render a different template.
      def index
        get_sorted_objects(params)  
        render :template => 'sortable/index'
      end
      
      # Users can also pass in optional conditions that are used by the finder method call. For example if only wanted to
      # show the items that had a certain status value you could pass in a condition 'mytable.status == 300' for example
      # as the conditions parameter and when the finder is called the sortable table will only display objects that meet those
      # conditions. Additionally you can paginate and sort the objects that are returned and apply the conditions to them.
      def get_sorted_objects(params, options={})                           
        objects = options[:objects].nil? ? sortable_class : options[:objects]
        include_rel = options[:include_relations].nil? ? sortable_include_relations : options[:include_relations]
        @headings = options[:table_headings].nil? ? sortable_table_headings : options[:table_headings]
        sort_map = options[:sort_map].nil? ? sortable_sort_map : HashWithIndifferentAccess.new(options[:sort_map])
        default_sort = options[:default_sort].nil? ? sortable_default_sort : options[:default_sort]
        conditions = options[:conditions].nil? ? '' : options[:conditions]
        search_array = options[:search_array].nil? ? sortable_search_array : options[:search_array]
        
        conditions = process_search(params, conditions, search_array)
        items_per_page = options[:per_page].nil? ? sortable_per_page : options[:per_page]
       
        @sort_map = sort_map
        sort = process_sort(params, sort_map, default_sort)
        page = params[:page]
        page ||= 1
        # fetch the objects, paginated and sorted as desired along with any extra filtering conditions
        get_paginated_objects(objects, sort, include_rel, conditions, page, items_per_page)
      end
      
      private
      def get_paginated_objects(objects, sort, include_rel, conditions, page, items_per_page)
        @objects = objects.paginate(:include => include_rel, 
                                 :order => sort, 
                                 :conditions => conditions,
                                 :page => page,
                                 :per_page => items_per_page)
      end

      def process_search(params, conditions, search_array)
        if !params[:q].blank?
          columns_to_search = ''
          values = Array.new        
          g = Generator.new(search_array)
          g.each do |col|
           columns_to_search += col + ' LIKE ? '
           columns_to_search += 'OR ' unless g.end?
           values<< "%#{params[:q]}%"
          end
          conditions += ' and' if !conditions.blank?
          conditions = [conditions + ' (' + columns_to_search + ')'] + values
        end
        return conditions
      end

      def value_provided?(params, name)
        !params[name].nil? && !params[name].empty?
      end

      def process_sort(params, sort_map, default_sort)
        if params['sort']
          sort = process_sort_param(params['sort'], sort_map)  
        else
          # fetch the table.column from the sortmap for the given sort key and append the sort direction
          sort = sort_map[default_sort[0]][0] + ' ' + default_sort[1]            
          
          # These variables are used in the sort_link_helper and sort_td_class_helper to build the column link headings
          # and create the proper CSS class for the column heading for the case where there is no sort param.
          @default_sort = default_sort[0]
          if default_sort[1] && default_sort[1] == 'DESC'
            @default_sort_key = default_sort[0] + '_reverse'
            @sortclass = 'sortup'       
          else
            @default_sort_key = default_sort[0]             
            @sortclass = 'sortdown'
          end
        end      
        return sort    
      end

      def process_sort_param(sort, sort_map)
        mapKey = get_sort_key(sort)
        
        if sort_map[mapKey].nil? 
          raise Exception.new("Invalid sort parameter passed #{sort}")
        end
        
        result = ''
        sort_array = sort_map[mapKey]
        # this adds support for more than one sort criteria for a given column
        # for example, status DESC, created_at ASC
        if sort_array[0].class == Array
          g = Generator.new(sort_array)
          g.each do |sort_value|
            result = get_sort_direction(sort, sort_value)
            result += ', ' unless g.end?
          end
        else
          result = get_sort_direction(sort, sort_array)
        end
        
        return result
      end
      
      def get_sort_direction(sort, sort_value)
        result = ''
        column = sort_value[0]
        direction = sort_value[1]
        if /_reverse$/.match(sort)
          if direction == 'DESC'
            direction = 'ASC'
          else
            direction = 'DESC'
          end
        end
        result += column + ' ' + direction        
      end
      
      def get_sort_key(sort)
        i = sort.index('_reverse')
        if i
          mapKey = sort[0, i]
        else
          mapKey = sort
        end
        return mapKey
      end
    end
    
end
