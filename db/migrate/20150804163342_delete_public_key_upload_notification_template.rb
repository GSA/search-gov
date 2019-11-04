class DeletePublicKeyUploadNotificationTemplate < ActiveRecord::Migration
  def up
    EmailTemplate.where(name: 'public_key_upload_notification').destroy_all
  end

  def down
  end
end
