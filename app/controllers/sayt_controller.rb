class SaytController < ActionController::Metal
  SAYT_SUGGESTION_SIZE = 15
  SAYT_SUGGESTION_SIZE_FOR_MOBILE = 6
  MOBILE_REGEXP = Regexp.new(ActionController::MobileFu::MOBILE_USER_AGENTS, true)

  def index
    Rails.logger.silence do
      query = params['q'] || ''
      sanitized_query = query.gsub('\\', '').squish.strip
      unless sanitized_query.empty?
        num_suggestions = mobile?(request.user_agent) ? SAYT_SUGGESTION_SIZE_FOR_MOBILE : SAYT_SUGGESTION_SIZE
        auto_complete_options = Search.suggestions(params['aid'], sanitized_query, num_suggestions)
        self.response_body = "#{params['callback']}(#{auto_complete_options.map { |option| option.phrase }.to_json})"
        self.content_type = "application/json"
      else
        self.response_body = ""
      end
    end
  end

  def mobile?(ua)
    ua =~ MOBILE_REGEXP
  end
end
