class CreateAffiliateFeatureAddition < ActiveRecord::Migration
  def self.up
    create_table :affiliate_feature_additions do |t|
      t.references :affiliate, :null => false
      t.references :feature, :null => false
      t.datetime :created_at, :null => false
    end
    add_index :affiliate_feature_additions, [:affiliate_id, :feature_id], :unique => true
  end

  def self.down
    drop_table :affiliate_feature_additions
  end
end
