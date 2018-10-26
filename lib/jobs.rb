module Jobs
  SIMPLE_SEARCHES = '(job|employment|internship)s?'
  JOB_RELATED_KEYWORDS = '((position|opening|posting|job|employment|intern(ship)?|seasonal|trabajo|puesto|empleo|vacante)s?|(opportunit|vacanc)(y|ies))|(posicion|ocupacion|oportunidad|federal)es|gobierno'
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

  def self.establish_connection!
    usajobs_api_config = Rails.application.secrets.jobs
    @endpoint = usajobs_api_config['endpoint']
    @usajobs_api_connection = Faraday.new('https://data.usajobs.gov') do |conn|
      #conn.response :logger, @logger, :bodies => true
      conn.headers['Authorization-Key'] = 'Qbk5RB/WRc1ctYqwojqlSKeoLVrwokT8OnSLq+G1qu0='
      conn.headers['User-Agent'] = 'parissa.eggleston@gmail.com'
      conn.request :json
      conn.response :mrashify
      conn.response :json
      conn.use :instrumentation
      conn.adapter Faraday.default_adapter
    end
    #Rails.logger.debug "-------"
    #Rails.logger.debug @usajobs_api_connection.to_yaml
    #Rails.logger.debug "-------"
    @usajobs_api_connection.headers[:accept] = 'application/vnd.usagov.position_openings.v3'
  end

  def self.search(options)
    @usajobs_api_connection.get(@endpoint, options).body if query_eligible?(options[:query])
  rescue => error
    Rails.logger.error("Trouble fetching jobs information: #{error}")
    nil
  end

  def self.query_eligible?(query)
    query =~ /\b#{JOB_RELATED_KEYWORDS}\b/i && !(query =~ /\b#{BLOCKED_KEYWORDS}\b/i) && !(query =~ /["():]|^-| -\S+/)
  end

end

Jobs.establish_connection!
