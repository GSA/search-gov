class RemoveTemplateClassicAndTemplateRoudnedTables < ActiveRecord::Migration
  def up
    drop_table :template_classics
    drop_table :template_rounded_header_links
  end

  def down
     create_table :template_rounded_header_links do |t|
      t.timestamps
    end
    create_table :template_classics do |t|
      t.timestamps
    end
  end
end
