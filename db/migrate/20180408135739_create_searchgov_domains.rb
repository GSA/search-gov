class CreateSearchgovDomains < ActiveRecord::Migration
  def change
    create_table :searchgov_domains do |t|
      t.string :domain, null: false
      t.boolean :clean_urls, null: false, default: true
      t.string :status
      t.integer :urls_count, null: false, default: 0
      t.integer :unfetched_urls_count, null: false, default: 0

      t.timestamps null: false
    end

    add_index :searchgov_domains, :domain, length: 100, unique: true
  end
end
