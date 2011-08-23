class CreateExcludedDomains < ActiveRecord::Migration
  def self.up
    create_table :excluded_domains do |t|
      t.string :domain

      t.timestamps
    end
  end

  def self.down
    drop_table :excluded_domains
  end
end
