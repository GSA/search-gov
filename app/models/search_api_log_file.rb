class SearchApiLogFile < LogFile

  class << self

    def parse_and_emit_line(api_log_entry)
      log = Apache::Log::Combined.parse(api_log_entry)
      return unless log.path.include?('?')
      query_string = log.path.split('?')[1]
      return if query_string.blank?
      params_hash = CGI.parse(query_string)
      return unless params_hash["query"][0].present? and
        params_hash["api_key"][0].present? and
        params_hash["affiliate"][0].present? and
        (User.find_by_api_key(params_hash["api_key"][0]).affiliates.exists?(:name => params_hash["affiliate"][0]) rescue false)
      query = params_hash["query"][0].gsub("\t", ' ')
      normalized_query = normalize(query)
      ipaddr = log.remote_ip
      return if skippable_query(query) or skippable_query(normalized_query) or skippable_request_string(query_string)
      time_of_day = log.time.strftime("%H:%M:%S")
      affiliate = params_hash["affiliate"][0].downcase
      locale = get_locale(params_hash["locale"][0])
      line = [ipaddr, time_of_day, log.path, query, normalized_query, affiliate, locale]
      puts line.join("\t")
    end

  end
end