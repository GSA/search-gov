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
      affiliate_id = if params[:name]
                       affiliate = Affiliate.select(:id).find_by_name_and_is_sayt_enabled(params[:name], true)
                       affiliate ? affiliate.id : nil
                     elsif params[:aid] && Affiliate.exists?(:id => params[:aid], :is_sayt_enabled => true)
                       params[:aid].to_i
                     end

      if affiliate_id
        options = {
            affiliate_id: affiliate_id,
            query: sanitized_query,
            number_of_results: is_mobile_device? ? SAYT_SUGGESTION_SIZE_FOR_MOBILE : SAYT_SUGGESTION_SIZE,
            extras: params[:extras].present?
        }
        search = SaytSearch.new(options)
        self.response_body = "#{params[:callback]}(#{search.results.to_json})"
        self.content_type = "application/json"
      else
        self.response_body = ''
      end
    end

    Rails.logger.level = original_logger_level
  end
end
