class AddEsUrlToAgencies < ActiveRecord::Migration
  def self.up
    add_column :agencies, :es_url, :string
  end

  def self.down
    remove_column :agencies, :es_url
  end
end
