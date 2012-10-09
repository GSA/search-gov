class SaytController < ActionController::Metal
  include AbstractController::Helpers
  include AbstractController::Callbacks
  include ActionController::MobileFu
  has_mobile_fu

  SAYT_SUGGESTION_SIZE = 10
  SAYT_SUGGESTION_SIZE_FOR_MOBILE = 6

  def index
    original_logger_level = Rails.logger.level
    Rails.logger.level = 7

    query = params[:q] || ''
    sanitized_query = query.gsub('\\', '').squish
    if sanitized_query.empty?
      self.response_body = ''
    else
      # Find the appropriate affiliate
      affiliate_id = if params[:name]
        Affiliate.select(%w(id)).find_by_name_and_is_sayt_enabled(params[:name], true).try(:id)
      elsif params[:aid]
        Affiliate.exists?(:id => params[:aid], :is_sayt_enabled => true) && params[:aid].to_i
      end

      # Build the SaytSearch
      num_suggestions = is_mobile_device? ? SAYT_SUGGESTION_SIZE_FOR_MOBILE : SAYT_SUGGESTION_SIZE
      search = SaytSearch.new(sanitized_query, num_suggestions)
      search.affiliate_id = affiliate_id
      search.extras = params[:extras].present?

      self.response_body = "#{params[:callback]}(#{search.results.to_json})"
      self.content_type = "application/json"
    end

    Rails.logger.level = original_logger_level
  end
end
