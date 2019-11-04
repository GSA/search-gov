class SeedUpdateExternalTrackingCodeEmailTemplate < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates ['update_external_tracking_code']
  end

  def self.down
    EmailTemplate.where(name: 'update_external_tracking_code').destroy_all
  end
end
