# frozen_string_literal: true

class ContentSettingsUpdater
  def update(args)
    ids = args == 'all' ? Affiliate.all.ids : args.split
    update_content_setings(ids)
  end

  private

  def update_content_setings(ids)
    updated_list = []
    failed_list = []

    Affiliate.where(id: ids).find_each do |affiliate|
      update_affiliate_content_setings(affiliate)
      updated_list << affiliate.id
    rescue StandardError => e
      failed_list << { affiliate_id: affiliate.id, reason: e.inspect }
    end

    log_completion(updated_list, failed_list)
    [updated_list, failed_list]
  end

  def update_affiliate_content_setings(affiliate)
    migrate_paperclip_image_to_active_storage(affiliate)
    update_alt_text(affiliate)
    update_header_links(affiliate)
    update_footer_links(affiliate)
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

  def update_header_links(affiliate)
    return if affiliate.managed_header_links.blank?

    new_header_urls = affiliate.primary_header_links.map(&:url)
    affiliate.managed_header_links.each do |link|
      next if new_header_urls.include?(link[:url])

      PrimaryHeaderLink.create(position: link[:position], type: 'PrimaryHeaderLink', title: link[:title], url: link[:url], affiliate_id: affiliate.id)
    end
  end

  def update_footer_links(affiliate)
    return if affiliate.managed_footer_links.blank?

    new_footer_urls = affiliate.footer_links.map(&:url)
    affiliate.managed_footer_links.each do |link|
      next if new_footer_urls.include?(link[:url])

      FooterLink.create(position: link[:position], type: 'FooterLink', title: link[:title], url: link[:url], affiliate_id: affiliate.id)
    end
  end

  def log_completion(updated_list, failed_list)
    Rails.logger.info("[content_settings_updater_task] The following affiliates were updated successfully: #{updated_list}.") if updated_list.present?
    Rails.logger.error("[content_settings_updater_task] The following affiliates failed to update: #{failed_list}.") if failed_list.present?
  end
end
