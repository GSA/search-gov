class CreateCseAnnotation < ActiveRecord::Migration
  def change
    create_table :cse_annotations do |t|
      t.string :url, null: false
      t.string :comment

      t.timestamps
    end
  end
end
