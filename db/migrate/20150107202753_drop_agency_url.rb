class DropAgencyUrl < ActiveRecord::Migration
  def up
    drop_table :agency_urls
  end

  def down
    create_table :agency_urls do |t|
      t.references :agency
      t.string :url
      t.string :locale
      t.timestamps
    end
  end
end
