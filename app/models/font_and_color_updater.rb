# frozen_string_literal: true

class FontAndColorUpdater
  def update(args)
    ids = args == 'all' ? Affiliate.where.not(visual_design_json: nil).ids : args.split
    update_font_and_color(ids)
  end

  private

  def update_font_and_color(ids)
    updated_list = []
    failed_list = []

    Affiliate.where(id: ids).find_each do |affiliate|
      update_affiliate_font_and_color(affiliate)
      updated_list << affiliate.id
    rescue StandardError => e
      failed_list << { affiliate_id: affiliate.id, reason: e.inspect }
    end

    log_completion(updated_list, failed_list)
    [updated_list, failed_list]
  end

  def update_affiliate_font_and_color(affiliate)
    affiliate.visual_design_json = Affiliate::DEFAULT_VISUAL_DESIGN
    affiliate.save
  end

  def log_completion(updated_list, failed_list)
    Rails.logger.info("[font_and_color_updater_task] The following affiliates were updated successfully: #{updated_list}.") if updated_list.present?
    Rails.logger.error("[font_and_color_updater_task] The following affiliates failed to update: #{failed_list}.") if failed_list.present?
  end
end
