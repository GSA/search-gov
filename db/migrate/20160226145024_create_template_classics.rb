class CreateTemplateClassics < ActiveRecord::Migration
  def change
    create_table :template_classics do |t|
      t.timestamps
    end
  end
end
