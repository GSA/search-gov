class CreateCommonSubstrings < ActiveRecord::Migration
  def self.up
    create_table :common_substrings do |t|
      t.references :indexed_domain, :null => false
      t.text :substring, :null => false
      t.float :saturation, :default => 0.0

      t.timestamps
    end
    add_index :common_substrings, :indexed_domain_id
  end

  def self.down
    drop_table :common_substrings
  end
end
