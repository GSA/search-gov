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
    log = Apache::Log::Combined.parse log_entry
    datetime = log.time
    ipaddr = log.remote_ip
    return unless log.path.include?('?')
    query_string = log.path.split('?')[1]
    parsed_log = CGI.parse(query_string)
    query = parsed_log["query"][0]
    affiliate = parsed_log["affiliate"][0].blank? ? "usasearch.gov" : parsed_log["affiliate"][0] 
    return if query.nil?
    noquery = parsed_log["noquery"][0]
    Query.create!(:query => query.strip, :affiliate => affiliate, :ipaddr => ipaddr, :timestamp => datetime) if noquery.nil?
  end

  def self.process_clicks(filepath)
    RAILS_DEFAULT_LOGGER.info("Processing file for clicks: #{filepath}")
    File.open(filepath) do |file|
      failures = []
      while log_entry = file.gets
        parse_line_for_click(log_entry) rescue failures << log_entry
      end
      RAILS_DEFAULT_LOGGER.warn("File #{filepath} has #{failures.size} errors: #{failures.inspect}") if failures.size > 0
    end
  end
  
  def self.parse_line_for_click(log_entry)
    log = Apache::Log::Combined.parse log_entry
    queried_at = log.time
    ip_address = log.remote_ip
    if log.path.include?('?')
      query_string = log.path.split('?')[1]
      parsed_log = CGI.parse(query_string)
      url = parsed_log["url"][0]
      if !url.nil?
        captures = url.match(/^(?:[^\/]+:\/\/)?([^\/:]+)/)
        host = captures[1]
        if host
          tld = host.split('.').last
          #unless tld == 'gov' || tld == 'mil'
            serp_position = parsed_log["rrank"][0].to_i
            source = parsed_log["rsource"][0]
            project = parsed_log["v:project"][0]
            affiliate = parsed_log["affiliate"][0].blank? ? "usasearch.gov" : parsed_log["affiliate"][0] 
            referrer = log.referer
            if referrer
              referrer_query_string = referrer.split('?')[1]
              if referrer_query_string
                parsed_referrer = CGI.parse(referrer_query_string)
                query = parsed_referrer['query'][0]
              end
            end
            Click.create!(:query => query, :queried_at => queried_at, :url => url, :serp_position => serp_position, :source => source, :project => project, :affiliate => affiliate, :host => host, :tld => tld)
          #end
        end
      end
    end
  end
end