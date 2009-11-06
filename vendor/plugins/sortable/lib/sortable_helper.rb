module SortableHelper
  # Helper method to generate a sortable table in the view
  # 
  # usage: <%= sortable_table(optional_params) %>
  # 
  # optional_params:
  # 
  # :paginate - Whether or not to display pagination links for the table. Default is true.
  # :partial - Name of the partial containing the table to display. Default is the table partial in the sortable
  #            plugin: 'sortable/table'
  #            
  #            If you choose to create your own partial in place of the one distributed with the sortable plugin 
  #            your partial has the following available to it for generating the table:
  #              @headings contains the table heading values
  #              @objects contains the collection of objects to be displayed in the table
  #              
  # :search - Whether or not to include a search field for the table. Default is true.
  #
  def sortable_table(options={})
    paginate = options[:paginate].nil? ? true : options[:paginate]
    partial = options[:partial].nil? ? 'sortable/table' : options[:partial]  
    search = options[:search].nil? ? true : options[:search]

    result = render(:partial => partial, :locals => {:search => search})
    result += will_paginate(@objects).to_s if paginate
    result
  end
 
    
  def sort_td_class_helper(param)
    result = 'sortup' if params[:sort] == param
    result = 'sortdown' if params[:sort] == param + "_reverse"
    result = @sortclass if @default_sort && @default_sort == param    
    return result
  end


  def sort_link_helper(action, text, param, params, extra_params={})
    options = build_url_params(action, param, params, extra_params)
    html_options = {:title => "Sort by this field"}        
    
    link_to(text, options, html_options)
  end

  def build_url_params(action, param, params, extra_params={})
    key = param
    if @default_sort_key && @default_sort == param
      key = @default_sort_key
    else
      key += "_reverse" if params[:sort] == param
    end
    params = {:sort => key, 
      :page => nil, # when sorting we start over on page 1
      :q => params[:q]}
    params.merge!(extra_params)

    return {:action => action, :params => params}
  end

   def row_cell_link(new_location)
     mouseover_pointer + "onclick='window.location=\"#{new_location}\"'"
   end

   def mouseover_pointer
     "onmouseover='this.style.cursor = \"pointer\"' onmouseout='this.style.cursor=\"auto\"'"
   end

   def table_header
     result = "<tr class='tableHeaderRow'>"
     	 @headings.each do |heading|
         sort_class = sort_td_class_helper heading[1]
      	 result += "<td"
   		   result += " class='#{sort_class}'" if !sort_class.blank? 
   		   result += ">"
   		   result += sort_link_helper @action, heading[0], heading[1], params
   		   result += "</td>"
   		end   
   		result += "</tr>"
   		return result
   end
end
