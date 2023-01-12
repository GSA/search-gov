class RenameWatcherConditionsColumns < ActiveRecord::Migration[7.0]
  def up
    rename_column :watchers, :conditions, :unsafe_conditions
    rename_column :watchers, :safe_conditions, :conditions
  end

  def down
    rename_column :watchers, :conditions, :safe_conditions
    rename_column :watchers, :unsafe_conditions, :conditions
  end
end
