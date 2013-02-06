class RenameActionNameOnHelpLinksToRequestPath < ActiveRecord::Migration
  def up
    remove_index :help_links, :action_name
    rename_column :help_links, :action_name, :request_path
    add_index :help_links, :request_path
  end

  def down
    remove_index :help_links, :request_path
    rename_column :help_links, :request_path, :action_name
    add_index :help_links, :action_name

  end
end
