class AddAffiliateIdToSaytSuggestions < ActiveRecord::Migration
  def self.up
    add_column :sayt_suggestions, :affiliate_id, :integer
  end

  def self.down
    remove_column :sayt_suggestions, :affiliate_id
  end
end
