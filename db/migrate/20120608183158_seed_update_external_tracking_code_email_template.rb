class SeedUpdateExternalTrackingCodeEmailTemplate < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates ['update_external_tracking_code']
  end

  def self.down
    EmailTemplate.destroy_all(:name => 'update_external_tracking_code')
  end
end
