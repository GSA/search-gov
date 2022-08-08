class ChangeDataTypeForWatcherConditions < ActiveRecord::Migration[6.1]
  def up
    # create a faux model to avoid JSON parsing of still-YAML content
    faux_watchers = Class.new ActiveRecord::Base
    faux_watchers.table_name = 'watchers'

    faux_watchers.select([:id, :conditions]).find_in_batches do |watchers|
      watchers.each do |watcher|
        begin
          watcher.conditions = YAML.load(watcher.conditions).to_json
          watcher.save!

        rescue Exception => e
          puts "Could not fix watcher #{watcher.id} for #{e.message}"
        end
      end
    end

    change_column :watchers, :conditions, :json
  end

  def down
    change_column :watchers, :conditions, :string
  end
end
