class SaytController < ActionController::Metal
  include AbstractController::Helpers
  include AbstractController::Callbacks
  include ActionController::MobileFu
  has_mobile_fu

  SAYT_SUGGESTION_SIZE = 15
  SAYT_SUGGESTION_SIZE_FOR_MOBILE = 6

  def index
    original_logger_level = Rails.logger.level
    Rails.logger.level = 7
    query = params[:q] || ''
    sanitized_query = query.gsub('\\', '').squish
    if sanitized_query.empty?
      self.response_body = ''
    else
      num_suggestions = is_mobile_device? ? SAYT_SUGGESTION_SIZE_FOR_MOBILE : SAYT_SUGGESTION_SIZE
      if params[:name]
        auto_complete_options = SaytSuggestion.like_by_affiliate_name(params[:name], sanitized_query, num_suggestions)
      elsif params[:aid]
        auto_complete_options = SaytSuggestion.like_by_affiliate_id(params[:aid], sanitized_query, num_suggestions)
      else
        auto_complete_options = []
      end
      self.response_body = "#{params[:callback]}(#{auto_complete_options.map(&:phrase).to_json})"
      self.content_type = "application/json"
    end
    Rails.logger.level = original_logger_level
  end
end
