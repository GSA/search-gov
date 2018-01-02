class CreateDomains < ActiveRecord::Migration
  def change
    create_table :domains do |t|
      t.string :domain, null: false
      t.boolean :retain_query_strings, null: false, default: false

      t.timestamps
    end
  end
end
