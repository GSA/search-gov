class AddMedlineMeshTitles < ActiveRecord::Migration
  def self.up
	add_column :med_topics, :mesh_titles, :string, :default => ""
  end

  def self.down
	remove_column :med_topics, :mesh_titles
  end
end
