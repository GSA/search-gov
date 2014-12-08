class DropCseAnnotation < ActiveRecord::Migration
  def up
    drop_table :cse_annotations
  end

  def down
    create_table :cse_annotations do |t|
      t.string :url, null: false
      t.string :comment

      t.timestamps
    end
  end
end
