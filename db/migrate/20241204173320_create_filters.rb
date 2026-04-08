class CreateFilters < ActiveRecord::Migration[7.1]
  def change
    create_table :filters do |t|
      t.integer :filter_setting_id
      t.string :type
      t.string :label
      t.boolean :enabled, default: false
      t.integer :position

      t.timestamps
    end
  end
end
