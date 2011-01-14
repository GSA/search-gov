class AddStagedAffiliateTemplateId < ActiveRecord::Migration
  def self.up
    add_column :affiliates, :staged_affiliate_template_id, :integer
    update("update affiliates set staged_affiliate_template_id =  affiliate_template_id")
  end

  def self.down
    remove_column :affiliates, :staged_affiliate_template_id
  end
end
