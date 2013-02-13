class CreateAffiliateNotes < ActiveRecord::Migration
  def change
    create_table :affiliate_notes do |t|
      t.references :affiliate
      t.text :note

      t.timestamps
    end
    add_index :affiliate_notes, :affiliate_id, unique: true
  end
end
