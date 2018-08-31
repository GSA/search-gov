class SaytController < ActionController::Metal
  include NewRelic::Agent::Instrumentation::ControllerInstrumentation

  SAYT_SUGGESTION_SIZE = 5

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
            number_of_results: SAYT_SUGGESTION_SIZE,
            extras: sayt_params[:extras].present?
        }
        search = SaytSearch.new(options)
        self.content_type = 'application/json'
        self.response_body = search.results.to_json
      else
        self.response_body = ''
      end
    end
    Rails.logger.level = original_logger_level
  end

  private

  def sayt_params
    @sayt_params ||= begin
      parameters = ActionController::Parameters.new(params)
      parameters.permit(:aid, :extras, :name, :q)
    end
  end
end
