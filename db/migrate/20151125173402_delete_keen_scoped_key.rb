class DeleteKeenScopedKey < ActiveRecord::Migration
  def up
    remove_column :affiliates, :keen_scoped_key
  end

  def down
    add_column :affiliates, :keen_scoped_key, :string
  end
end
