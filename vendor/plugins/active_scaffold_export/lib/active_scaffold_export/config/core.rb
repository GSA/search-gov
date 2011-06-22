# Need to open the AS module carefully due to Rails 2.3 lazy loading
ActiveScaffold::Config::Core.class_eval do
  # For some unobvious reasons, the class variables need to be defined
  # *before* the cattr !!
  self.send :class_variable_set, :@@export_show_form, true
  self.send :class_variable_set, :@@export_allow_full_download, true
  self.send :class_variable_set, :@@export_default_full_download, true
  self.send :class_variable_set, :@@export_force_quotes, false
  self.send :class_variable_set, :@@export_default_skip_header, false
  self.send :class_variable_set, :@@export_default_delimiter, ','
  
  cattr_accessor :export_show_form, :export_allow_full_download,
      :export_force_quotes, :export_default_full_download,
      :export_default_delimiter, :export_default_skip_header

  ActionDispatch::Routing::ACTIVE_SCAFFOLD_CORE_ROUTING[:collection][:show_export] = :get
  ActionDispatch::Routing::ACTIVE_SCAFFOLD_CORE_ROUTING[:collection][:export] = :post
end
