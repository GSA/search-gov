# frozen_string_literal: true

class ImageContentUpdater
  def update(args)
    ids = args == 'all' ? Affiliate.ids : args.split
    process_images(ids)
  end

  private

  def process_images(ids)
    updated_list = []
    failed_list = []
    update_image_content(ids, updated_list, failed_list)
    log_completion(updated_list, failed_list)
    [updated_list, failed_list]
  end

  def update_image_content(ids, updated_list, failed_list)
    time = Benchmark.measure do
      get_affiliates(ids).find_each do |affiliate|
        update_affiliate_image_content(affiliate)
        updated_list << affiliate.id
      rescue StandardError => e
        failed_list << { affiliate_id: affiliate.id, reason: e.inspect }
      end
    end
    Rails.logger.info "Migration completed in #{time.real.round(2)} seconds"
  end

  def get_affiliates(ids)
    Affiliate.left_outer_joins(:header_logo_attachment).
      where(active_storage_attachments: { id: nil }, id: ids).
      where.not(mobile_logo_file_name: nil)
  end

  def update_affiliate_image_content(affiliate)
    migrate_paperclip_image_to_active_storage(affiliate)
    update_alt_text(affiliate)
    affiliate.save
  end

  def migrate_paperclip_image_to_active_storage(affiliate)
    affiliate.header_logo.attach(io: URI.parse(affiliate.mobile_logo_url).open,
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
