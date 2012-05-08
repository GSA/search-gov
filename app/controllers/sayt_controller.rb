class SaytController < ActionController::Metal
  SAYT_SUGGESTION_SIZE = 15
  SAYT_SUGGESTION_SIZE_FOR_MOBILE = 6
  MOBILE_REGEXP = Regexp.new(ActionController::MobileFu::MOBILE_USER_AGENTS, true)
  include ActionController::Rendering
  include ActionController::Instrumentation

  def index
    Rails.logger.silence do
      query = params['q'] || ''
      sanitized_query = query.gsub('\\', '').squish
      if sanitized_query.empty?
        self.response_body = ""
      else
        num_suggestions = mobile?(request.user_agent) ? SAYT_SUGGESTION_SIZE_FOR_MOBILE : SAYT_SUGGESTION_SIZE
        auto_complete_options = WebSearch.suggestions(params['aid'], sanitized_query, num_suggestions)
        self.response_body = "#{params['callback']}(#{auto_complete_options.map(&:phrase).to_json})"
        self.content_type = "application/json"
      end
    end
  end

  def mobile?(ua)
    ua =~ MOBILE_REGEXP
  end
end
