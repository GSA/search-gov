class RemoveAffiliateTemplateColumnsFromAffiliates < ActiveRecord::Migration
  def self.up
    remove_column :affiliates, :affiliate_template_id
    remove_column :affiliates, :staged_affiliate_template_id
  end

  def self.down
    add_column :affiliates, :affiliate_template_id, :integer
    add_column :affiliates, :staged_affiliate_template_id, :integer
    add_index :affiliates, :affiliate_template_id
  end
end
