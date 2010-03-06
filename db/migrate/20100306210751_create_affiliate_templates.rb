class CreateAffiliateTemplates < ActiveRecord::Migration
  def self.up
    create_table :affiliate_templates do |t|
      t.string :name
      t.string :description
      t.string :stylesheet

      t.timestamps
    end
  end

  def self.down
    drop_table :affiliate_templates
  end
end
