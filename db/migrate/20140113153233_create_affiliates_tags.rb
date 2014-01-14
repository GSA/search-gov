class CreateAffiliatesTags < ActiveRecord::Migration
  def change
    create_table :affiliates_tags, id: false do |t|
      t.references :affiliate, null: false
      t.references :tag, null: false
    end

    add_index :affiliates_tags, [:affiliate_id, :tag_id], unique: true
  end
end
