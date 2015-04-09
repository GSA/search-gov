class DropAffiliateNotes < ActiveRecord::Migration
  def up
    drop_table :affiliate_notes
  end

  def down
    create_table :affiliate_notes do |t|
      t.references :affiliate
      t.text :note

      t.timestamps
    end
    add_index :affiliate_notes, :affiliate_id, unique: true
  end
end
