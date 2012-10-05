class CreateSystemAlerts < ActiveRecord::Migration
  def change
    create_table :system_alerts do |t|
      t.string :message, :null => false
      t.datetime :start_at, :null => false
      t.datetime :end_at
    end
  end
end
