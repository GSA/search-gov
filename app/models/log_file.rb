class LogFile < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  class << self

    def transform_to_hive_queries_format(filepath)
      failures = []
      File.open(filepath) do |file|
        while log_entry = file.gets
          parse_and_emit_line(log_entry) rescue failures << log_entry
        end
      end
      RAILS_DEFAULT_LOGGER.warn("File #{filepath} has #{failures.size} errors:\n#{failures}") unless failures.empty?
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
      return if skippable_query(query) or skippable_query(normalized_query) or params_hash["noquery"][0] or skippable_ip(ipaddr)
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

    def process(filepath)
      RAILS_DEFAULT_LOGGER.info("Processing file #{filepath}")
      File.open(filepath) do |file|
        failures = []
        while log_entry = file.gets
          parse_line(log_entry) rescue failures << log_entry
        end
        create!(:name=>File.basename(filepath))
        RAILS_DEFAULT_LOGGER.warn("File #{filepath} has #{failures.size} errors: #{failures.inspect}") if failures.size > 0
      end unless find_by_name(File.basename(filepath))
    end

    def parse_line(log_entry)
      log = Apache::Log::Combined.parse(log_entry) || Apache::Log::Common.parse(log_entry)
      datetime = log.time
      ipaddr = log.remote_ip
      agent = log.agent rescue nil
      is_bot = is_agent_a_bot?(agent) rescue nil
      return unless log.path.include?('?')
      query_string = log.path.split('?')[1]
      parsed_log = CGI.parse(query_string)
      query = parsed_log["query"][0]
      affiliate = parsed_log["affiliate"][0].blank? ? "usasearch.gov" : parsed_log["affiliate"][0]
      locale = parsed_log["locale"][0].blank? ? I18n.default_locale.to_s : parsed_log["locale"][0]
      is_contextual = parsed_log["linked"][0].present?
      return if skippable_query(query)
      noquery = parsed_log["noquery"][0]
      Query.create!(:query => query.strip, :affiliate => affiliate, :ipaddr => ipaddr, :timestamp => datetime, :locale => locale, :agent => agent, :is_bot => is_bot, :is_contextual => is_contextual) if noquery.nil?
    end

    private

    def is_agent_a_bot?(agent)
      return false if agent.blank?
      BOT_USER_AGENTS.detect { |bot| agent.downcase.include?(bot.downcase) }.present?
    end

    def skippable_query(query)
      query.nil? || query.empty? || query[0..3] == '"><a' || Query::DEFAULT_EXCLUDED_QUERIES.include?(query)
    end

    def skippable_ip(ip)
      Query::DEFAULT_EXCLUDED_IPADDRESSES.include?(ip)
    end

    def normalize(query)
      query.delete("'").gsub(",", ' ').squish.strip.downcase
    end
  end
end