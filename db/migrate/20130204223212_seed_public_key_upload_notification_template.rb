class SeedPublicKeyUploadNotificationTemplate < ActiveRecord::Migration
  def self.up
    EmailTemplate.load_default_templates ['public_key_upload_notification']
  end

  def self.down
    EmailTemplate.where(name: 'public_key_upload_notification').destroy_all
  end
end
