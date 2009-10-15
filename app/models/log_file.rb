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
    end unless LogFile.find_by_name(filepath)
  end

  def self.parse_line(log_entry)
    log = Apache::Log::Combined.parse log_entry
    datetime = log.time
    ipaddr = log.remote_ip
    parsed_log = CGI.parse(log.path)
    query = parsed_log["query"][0]
    affiliate = parsed_log["affiliate"][0] || "usasearch.gov"
    return if query.nil?
    noquery = parsed_log["noquery"][0]
    Query.create!(:query => query.strip, :affiliate => affiliate, :ipaddr => ipaddr, :timestamp => datetime) if noquery.nil?
  end
end