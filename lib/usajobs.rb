module Usajobs
  SIMPLE_SEARCHES = '(job|employment|internship)s?'
  JOB_RELATED_KEYWORDS = '((position|opening|posting|job|employment|internship)s?|(opportunit|vacanc)(y|ies))'
  SIMPLE_SINGULARS = %w{
    statistic number level rate description trend growth projection survey forecast figure report verification record
    authorization card classification form hazard poster fair board outlook grant funding factor other cut
    application
  }
  BLOCKED_PHRASES = '(job|employment) (contract|law|training|safety)s?'
  BLOCKED_KEYWORDS = 'data|at will|equal|status|eligibility|analysis|300 log|delayed'+
    '|(histor)(y|ies)'+
    "|#{Date.current.year.to_s}"+
    "|#{BLOCKED_PHRASES}"+
    "|(#{SIMPLE_SINGULARS.join('|')})s?"

  RATE_INTERVALS = {
    :BW => 'Bi-weekly',
    :FB => 'Fee Basis',
    :PA => 'Per Year',
    :PD => 'Per Day',
    :PH => 'Per Hour',
    :PM => 'Per Month',
    :PW => 'Piece Work',
    :ST => 'Student Stipend Paid',
    :SY => 'School Year',
    :WC => 'Without Compensation'}.freeze

  def self.establish_connection!
    usajobs_api_config = YAML.load_file("#{Rails.root}/config/usajobs.yml")
    @endpoint = usajobs_api_config['endpoint']
    @usajobs_api_connection = Faraday.new usajobs_api_config['host'] do |conn|
      conn.request :json
      conn.response :mashify
      conn.response :json
      conn.use :instrumentation
      conn.adapter usajobs_api_config['adapter'] || Faraday.default_adapter
    end
  end

  def self.search(options)
    if query_eligible?(options[:query])
      options[:query] = enhance_query(options[:query], options[:geoip_info]) if options[:geoip_info].present?
      @usajobs_api_connection.get(@endpoint, options).body
    end
  rescue Exception => e
    Rails.logger.error("Trouble fetching USAJobs information: #{e}")
    nil
  end

  def self.query_eligible?(query)
    query =~ /\b#{JOB_RELATED_KEYWORDS}\b/i && !(query =~ /\b#{BLOCKED_KEYWORDS}\b/i)
  end

  def self.enhance_query(query, geoip_info)
    simple_search_with_state = query =~ /^#{SIMPLE_SEARCHES}$/i &&
      geoip_info.present? && geoip_info.region_name.present? && State.member?(geoip_info.region_name)
    simple_search_with_state ? "#{query} in #{geoip_info.region_name}" : query
  end
end

Usajobs.establish_connection!