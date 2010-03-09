class AffiliatesBelongToAffiliateTemplates < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :affiliate_template_id, :integer
    add_index :affiliates, :affiliate_template_id
  end

  def self.down
    remove_column :affiliates, :affiliate_template_id
  end
end
