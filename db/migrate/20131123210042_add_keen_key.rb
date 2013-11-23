class AddKeenKey < ActiveRecord::Migration
  def change
    add_column :affiliates, :keen_scoped_key, :string
  end
end
