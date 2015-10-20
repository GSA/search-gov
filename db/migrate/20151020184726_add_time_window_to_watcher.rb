class AddTimeWindowToWatcher < ActiveRecord::Migration
  def change
    add_column :watchers, :time_window, :string
  end
end
