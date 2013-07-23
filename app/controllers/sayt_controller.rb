require 'airbrake/rails/controller_methods'

class SaytController < ActionController::Metal
  include AbstractController::Helpers
  include AbstractController::Callbacks
  include ActionController::MobileFu
  include Airbrake::Rails::ControllerMethods
  has_mobile_fu

  SAYT_SUGGESTION_SIZE = 10
  SAYT_SUGGESTION_SIZE_FOR_MOBILE = 6

  def index
    original_logger_level = Rails.logger.level
    Rails.logger.level = 7

    query = sayt_params[:q] || ''
    sanitized_query = query.gsub('\\', '').squish
    if sanitized_query.empty?
      self.response_body = ''
    else
      affiliate = if sayt_params[:name]
                    Affiliate.select([:id, :locale]).find_by_name_and_is_sayt_enabled(sayt_params[:name], true)
                  elsif sayt_params[:aid]
                    Affiliate.select([:id, :locale]).find_by_id_and_is_sayt_enabled(sayt_params[:aid], true)
                  end

      if affiliate
        options = {
            affiliate_id: affiliate.id,
            locale: affiliate.locale,
            query: sanitized_query,
            number_of_results: is_mobile_device? ? SAYT_SUGGESTION_SIZE_FOR_MOBILE : SAYT_SUGGESTION_SIZE,
            extras: sayt_params[:extras].present?
        }
        search = SaytSearch.new(options)
        self.response_body = "#{sayt_params[:callback]}(#{search.results.to_json})"
        self.content_type = "application/json"
      else
        self.response_body = ''
      end
    end

    Rails.logger.level = original_logger_level
  end

  private

  def sayt_params
    @sayt_params ||=
        params.slice(:aid, :callback, :extras, :name, :q).reject { |k, v| !v.is_a?(String) }
  end
end
