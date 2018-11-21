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
    @usajobs_api_connection = Faraday.new(usajobs_api_config['host']) do |conn|
      conn.headers['Authorization-Key'] = usajobs_api_config['authorization_key']
      conn.headers['User-Agent'] = usajobs_api_config['user_agent']
      conn.request :json
      conn.response :mrashify
      conn.response :json
      conn.use :instrumentation
      conn.adapter usajobs_api_config['adapter'] || Faraday.default_adapter
    end
  end

  def self.scrub_keyword(keyword)
    #Keep the job related keyword if its the only word being searched on so "" is not passed to api.
    scrubbed_keyword = keyword.remove(/\b#{JOB_RELATED_KEYWORDS}\b/, '').squish
    keyword =~ /^#{JOB_RELATED_KEYWORDS}$/ ? keyword : scrubbed_keyword
  end

  def self.search(job_options)
    if query_eligible?(job_options[:query])
      @usajobs_api_connection.get(@endpoint, params(job_options)).body
    end
  rescue => error
    Rails.logger.error("Trouble fetching jobs information: #{error}")
    nil
  end

  def self.query_eligible?(query)
    query =~ /\b#{JOB_RELATED_KEYWORDS}\b/i && !(query =~ /\b#{BLOCKED_KEYWORDS}\b/i) && !(query =~ /["():]|^-| -\S+/)
  end

  def self.params(options)
    { Keyword:        scrub_keyword(options[:query]),
      Organization:   options[:organization],
      LocationName:   options[:location_name],
      ResultsPerPage: options[:results_per_page]
    }
  end

end

Jobs.establish_connection!
