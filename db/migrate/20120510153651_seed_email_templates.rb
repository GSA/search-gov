class SeedEmailTemplates < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates
  end

  def self.down
    EmailTemplate.destroy_all
  end
end
