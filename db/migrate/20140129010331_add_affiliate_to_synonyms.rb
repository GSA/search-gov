class AddAffiliateToSynonyms < ActiveRecord::Migration
  def change
    add_column :synonyms, :affiliate_id, :integer
  end
end
