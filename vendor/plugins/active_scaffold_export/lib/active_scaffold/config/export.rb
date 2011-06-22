module ActiveScaffold::Config
  class Export < ActiveScaffold::Config::Form
    self.crud_type = :read

    def initialize(core_config)
      @core = core_config
    end

    # global level configuration
    # --------------------------
    # the ActionLink for this action
    cattr_accessor :link
    @@link = ActiveScaffold::DataStructures::ActionLink.new('show_export', :label => :export, :type => :collection, :security_method => :export_authorized?)

    # configures where the plugin itself is located. there is no instance version of this.
    cattr_accessor :plugin_directory
    @@plugin_directory = File.expand_path(__FILE__).match(%{(^.*)/lib/active_scaffold/config/export.rb})[1]


    # instance-level configuration
    # ----------------------------

    attr_writer :link
    def link
      @link ||= if show_form
        self.class.link.clone
      else
        ActiveScaffold::DataStructures::ActionLink.new('export', :label => :export, :type => :collection, :inline => false, :security_method => :export_authorized?)
      end
    end

    attr_writer :show_form, :allow_full_download, :force_quotes, :default_full_download, :default_delimiter, :default_skip_header, :default_deselected_columns
    def show_form
      self.show_form = @core.export_show_form if @show_form.nil?
      @show_form
    end
    def allow_full_download
      self.allow_full_download = @core.export_allow_full_download if @allow_full_download.nil?
      @allow_full_download
    end
    def force_quotes
      self.force_quotes = @core.export_force_quotes if @force_quotes.nil?
      @force_quotes
    end
    def default_full_download
      self.default_full_download = @core.export_default_full_download if @default_full_download.nil?
      @default_full_download
    end
    def default_delimiter
      self.default_delimiter = @core.export_default_delimiter if @default_delimiter.nil?
      @default_delimiter
    end
    def default_skip_header
      self.default_skip_header = @core.export_default_skip_header if @default_skip_header.nil?
      @default_skip_header
    end
    def default_deselected_columns
      self.default_deselected_columns = [] if @default_deselected_columns.nil?
      @default_deselected_columns
    end

    # provides access to the list of columns specifically meant for this action to use
    def columns
      self.columns = @core.columns._inheritable unless @columns
      @columns
    end
    def columns=(val)
      @columns = ActiveScaffold::DataStructures::ActionColumns.new(*val)
      @columns.action = self
    end

    def multipart?
      false
    end
  end
end
