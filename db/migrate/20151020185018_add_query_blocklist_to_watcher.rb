class AddQueryBlocklistToWatcher < ActiveRecord::Migration
  def change
    add_column :watchers, :query_blocklist, :string
  end
end
