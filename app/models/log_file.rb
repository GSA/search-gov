class LogFile < ActiveRecord::Base
  validates_presence_of :name
  validates_uniqueness_of :name

  def self.process(filepath)
    RAILS_DEFAULT_LOGGER.info("Processing file #{filepath}")
    File.open(filepath) do |file|
      failures = []
      while log_entry = file.gets
        parse_line(log_entry) rescue failures << log_entry
      end
      LogFile.create!(:name=>File.basename(filepath))
      RAILS_DEFAULT_LOGGER.warn("File #{filepath} has #{failures.size} errors: #{failures.inspect}") if failures.size > 0
    end unless LogFile.find_by_name(File.basename(filepath))
  end

  def self.parse_line(log_entry)
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
    is_contextual = parsed_log["linked"][0].present? ? (parsed_log["linked"][0] == "1" ? true : false) : false
    return if query.nil? or invalid_query(query)
    noquery = parsed_log["noquery"][0]
    Query.create!(:query => query.strip, :affiliate => affiliate, :ipaddr => ipaddr, :timestamp => datetime, :locale => locale, :agent => agent, :is_bot => is_bot, :is_contextual => is_contextual) if noquery.nil?
  end

  private

  def self.is_agent_a_bot?(agent)
    BOT_USER_AGENTS.detect { |bot| agent.downcase.include?(bot.downcase) }.present?
  end
  
  def self.invalid_query(query)
    query[0..2] == '><a' ? true : false
  end
end