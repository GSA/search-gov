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
      affiliate = nil
      if params[:name]
        affiliate = Affiliate.select(%w(id name)).find_by_name_and_is_sayt_enabled(params[:name], true)
      elsif params[:aid]
        affiliate = Affiliate.select(%w(id name)).find_by_id_and_is_sayt_enabled(params[:aid], true)
      end

      # Build the SaytSearch
      num_suggestions = is_mobile_device? ? SAYT_SUGGESTION_SIZE_FOR_MOBILE : SAYT_SUGGESTION_SIZE
      search = SaytSearch.new(sanitized_query, num_suggestions)
      search.affiliate = affiliate

      self.content_type = "application/json"
      self.response_body = "#{params[:callback]}(#{search.results.to_json})"
    end

    Rails.logger.level = original_logger_level
  end
end
