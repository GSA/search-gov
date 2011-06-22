ACTIVE_SCAFFOLD_EXPORT_PLUGIN = true
require 'active_scaffold_export'
begin
  ActiveScaffoldAssets.copy_to_public(ActiveScaffoldExport.root)
rescue
  raise $! unless Rails.env == 'production'
end

