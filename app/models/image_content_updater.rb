# frozen_string_literal: true

class ImageContentUpdater
    def update(args)
      ids = args == 'all' ? Affiliate.all.ids : args.split
      update_image_content(ids)
    end
  
    private
  
    def update_image_content(ids)
      updated_list = []
      failed_list = []
  
      Affiliate.where(id: ids).find_each do |affiliate|
        update_affiliate_image_content(affiliate)
        updated_list << affiliate.id
      rescue StandardError => e
        failed_list << { affiliate_id: affiliate.id, reason: e.inspect }
      end
  
      log_completion(updated_list, failed_list)
      [updated_list, failed_list]
    end
  
    def update_affiliate_image_content(affiliate)
      migrate_paperclip_image_to_active_storage(affiliate)
      update_alt_text(affiliate)
      affiliate.save
    end
  
    def migrate_paperclip_image_to_active_storage(affiliate)
      return if affiliate.mobile_logo_file_name.blank?
  
      logo_url = affiliate.send(:mobile_logo).url.sub(Rails.env, 'production').gsub(' ', '%20')
      affiliate.header_logo.attach(io: Tempfile.open(logo_url),
                                   filename: affiliate.mobile_logo_file_name,
                                   content_type: affiliate.mobile_logo_content_type)
    end
  
    def update_alt_text(affiliate)
      affiliate.header_logo_blob.metadata.merge!({ 'custom' => { 'alt_text' => affiliate.logo_alt_text.to_s } }) if affiliate.logo_alt_text.present?
    end
  
    def log_completion(updated_list, failed_list)
      Rails.logger.info("[image_content_updater_task] The following affiliates were updated successfully: #{updated_list}.") if updated_list.present?
      Rails.logger.error("[image_content_updater_task] The following affiliates failed to update: #{failed_list}.") if failed_list.present?
    end
  end
  