class SearchImpression
  IRRELEVANT_KEYS = %w(utf8 m controller action)

  def self.log(search, vertical, params, request)
    request_pairs = { clientip: request.remote_ip, request: request.url, referrer: request.referer, user_agent: request.user_agent }
    relevant_params = params.reject { |k, v| IRRELEVANT_KEYS.include?(k) }
    hash = request_pairs.merge(time: Time.now.to_formatted_s(:db),
                               vertical: vertical,
                               modules: search.modules.join('|'),
                               params: relevant_params)
    Rails.logger.info("[Search Impression] #{hash.to_json}")
  end
end
