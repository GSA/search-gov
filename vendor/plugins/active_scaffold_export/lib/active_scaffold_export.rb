require "csv"
if CSV.const_defined? :Reader
  # Ruby 1.8 compatible
  begin
    require 'fastercsv'
    Object.send(:remove_const, :CSV)
    CSV = FasterCSV
  rescue Gem::LoadError
    raise "For ruby 1.8, the 'fastercsv' gem is required"
  end
else
  # CSV is now FasterCSV in ruby 1.9
end

# Make sure that ActiveScaffold has already been included
ActiveScaffold rescue throw "should have included ActiveScaffold plug in first.  Please make sure that this plug-in comes alphabetically after the ActiveScaffold plug-in"


# Load our overrides
require "active_scaffold_export/config/core.rb"

module ActiveScaffoldExport
  def self.root
    File.dirname(__FILE__) + "/.."
  end
end

module ActiveScaffold
  module Actions
    ActiveScaffold.autoload_subdir('actions', self, File.dirname(__FILE__))
  end

  module Config
    ActiveScaffold.autoload_subdir('config', self, File.dirname(__FILE__))
  end

  module Helpers
    ActiveScaffold.autoload_subdir('helpers', self, File.dirname(__FILE__))
  end
end

# Register our helper methods
ActionView::Base.send(:include, ActiveScaffold::Helpers::ExportHelpers)


##
## Run the install assets script, too, just to make sure
## But at least rescue the action in production
##
if defined?(ACTIVE_SCAFFOLD_EXPORT_PLUGIN)
  ActiveScaffoldAssets.copy_to_public(ActiveScaffoldExport.root)
else
  Rails::Application.initializer("active_scaffold_export.install_assets", :after => "active_scaffold.install_assets") do
    ActiveScaffoldAssets.copy_to_public(ActiveScaffoldExport.root)
  end
end
