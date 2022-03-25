class DropAffiliateTemplatesTable < ActiveRecord::Migration[6.1]
  def up
    drop_table :affiliate_templates
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
