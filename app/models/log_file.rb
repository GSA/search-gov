class LogFile

  class << self

    def transform_to_hive_queries_format(filepath)
      failures = []
      File.open(filepath) do |file|
        while log_entry = file.gets
          parse_and_emit_line(log_entry) rescue failures << log_entry
        end
      end
      Rails.logger.warn("File #{filepath} has #{failures.size} errors:\n#{failures}") unless failures.empty?
    end

    def parse_and_emit_line(log_entry)
      log = Apache::Log::Combined.parse(log_entry) || Apache::Log::Common.parse(log_entry)
      return unless log.path.include?('?')
      query_string = log.path.split('?')[1]
      return if query_string.blank?
      params_hash = CGI.parse(query_string)
      return unless params_hash["query"][0].present?
      query = params_hash["query"][0].gsub("\t", ' ')
      normalized_query = normalize(query)
      ipaddr = log.remote_ip
      return if skippable_query(query) or skippable_query(normalized_query) or params_hash["noquery"][0] or skippable_ip(ipaddr) or skippable_request_string(query_string)
      time_of_day = log.time.strftime("%H:%M:%S")
      referrer = log.referer rescue ''
      agent = log.agent rescue ''
      affiliate = params_hash["affiliate"][0].blank? ? Affiliate::USAGOV_AFFILIATE_NAME : params_hash["affiliate"][0]
      return unless Affiliate.exists?(:name => affiliate) or affiliate == Affiliate::USAGOV_AFFILIATE_NAME
      affiliate.downcase!
      locale = params_hash["locale"][0] == 'es' ? 'es' : I18n.default_locale.to_s
      is_bot = is_agent_a_bot?(agent) ? 1 : 0
      is_contextual = params_hash["linked"][0].present? ? 1 : 0
      line = [ipaddr, time_of_day, log.path, log.size, referrer, agent, query, normalized_query, affiliate, locale, is_bot, is_contextual]
      puts line.join("\t")
    end

    private

    def is_agent_a_bot?(agent)
      return false if agent.blank?
      BOT_USER_AGENTS.detect { |bot| agent.downcase.include?(bot.downcase) }.present?
    end

    def skippable_request_string(query_string)
      LogfileBlockedRegexp.all.detect { |filter| query_string =~ /#{filter.regexp}/ }
    end

    def skippable_query(query)
      query.nil? || query.empty? || LogfileBlockedQuery.find_by_query(query)
    end

    def skippable_ip(ip)
      classc = ip.split('.')[0,3].join('.')
      LogfileBlockedIp.find_by_ip(ip) or LogfileBlockedClassC.find_by_classc(classc)
    end

    def normalize(query)
      query.gsub(",", ' ').squish.strip.downcase
    end
  end
end