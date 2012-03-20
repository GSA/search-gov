class CreateHelpLinks < ActiveRecord::Migration
  def self.up
    create_table :help_links do |t|
      t.string :action_name
      t.string :help_page_url

      t.timestamps
    end
    add_index :help_links, :action_name
  end

  def self.down
    drop_table :help_links
  end
end
