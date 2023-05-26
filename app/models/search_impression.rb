class SearchImpression
  IRRELEVANT_KEYS = %w(access_key action api_key controller m utf8)

  def self.log(search, vertical, params, request)
    url = get_url_from_request(request)

    request_pairs = {
      clientip: request.remote_ip,
      request: UrlParser.redact_query(url),
      referrer: UrlParser.redact_query(request.referer),
      user_agent: request.user_agent
    }
    request_pairs[:diagnostics] = flatten_diagnostics_hash(search.diagnostics)
    hash = request_pairs.merge(time: Time.now.to_fs(:db),
                               vertical: vertical,
                               modules: search.modules.join('|'),
                               params: clean_params(params))

    Rails.logger.info("[Search Impression] #{hash.to_json}")
  end

  def self.clean_params(params)
    params.reject! { |k, v| IRRELEVANT_KEYS.include?(k.to_s) || k.to_s.include?('.') }
    params['query'] = Redactor.redact(params['query'])
    params
  end

  def self.get_url_from_request(request)
    if ! request.headers['X-Original-Request'].to_s.empty?
      Rails.logger.info("[X-Original-Request] (#{request.headers['X-Original-Request'].inspect})")
      request.headers['X-Original-Request']
    else
      request.url
    end
  end

  def self.flatten_diagnostics_hash(diagnostics_hash)
    diagnostics_hash.keys.sort.map { |k| diagnostics_hash[k].merge(module: k) }
  end
end
