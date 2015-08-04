class DeletePublicKeyUploadNotificationTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.destroy_all(:name => 'public_key_upload_notification')
  end

  def down
  end
end
