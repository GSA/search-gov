# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)
require 'mobile_fu'

class Sayt
  SAYT_SUGGESTION_SIZE = 15
  SAYT_SUGGESTION_SIZE_FOR_MOBILE = 6
  MOBILE_REGEXP = Regexp.new(ActionController::MobileFu::MOBILE_USER_AGENTS, true)

  def self.call(env)
    if env['PATH_INFO'] =~ /^\/sayt/
      params = Rack::Request.new(env).params
      query, response = params['q'], ''
      if query
        sanitized_query = query.gsub('\\', '').squish.strip
        num_suggestions = mobile?(env['HTTP_USER_AGENT']) ? SAYT_SUGGESTION_SIZE_FOR_MOBILE : SAYT_SUGGESTION_SIZE
        auto_complete_options = Search.suggestions(sanitized_query, num_suggestions)
        response = "#{params['callback']}(#{auto_complete_options.map { |option| option.phrase }.to_json})"
      end
      [200, {"Content-Type" => "application/json"}, [response]]
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end

  def self.mobile?(ua)
    ua =~ MOBILE_REGEXP
  end
end
