# frozen_string_literal: true

module Jobs
  SIMPLE_SEARCHES = '(job|employment|internship)s?'
  JOB_RELATED_KEYWORDS = '((position|opening|posting|job|employment|career|' \
                         'intern(ship)?|seasonal|trabajo|puesto|empleo|' \
                         'carrera|vacante+?)(s\b|\b)|(opportunit|vacanc)' \
                         '(y|ies))|(posicion|ocupacion|oportunidad)' \
                         '(es)?'
  SCRUB_KEYWORDS = JOB_RELATED_KEYWORDS.
                     remove(/\|intern\(ship\)|\|seasonal/)
  SIMPLE_SINGULARS = %w[
    statistic number level rate description trend growth
    projection survey forecast figure report verification record
    authorization card classification form hazard poster fair board
    outlook grant funding factor other cut
    application
  ].freeze
  BLOCKED_PHRASES = '(job|employment) (contract|law|training|safety)s?'
  BLOCKED_KEYWORDS =
    'data|at will|equal|status|eligibility|analysis|300 log|delayed' \
    '|(histor)(y|ies)' \
    "|#{Date.current.year.to_s}" \
    "|#{BLOCKED_PHRASES}" \
    "|(#{SIMPLE_SINGULARS.join('|')})s?"
  SEARCH_RADIUS = 75

  def self.establish_connection!
    usajobs_api_config = Rails.application.secrets.jobs
    @endpoint = usajobs_api_config[:endpoint]
    @usajobs_api_connection = Faraday.new(usajobs_api_config[:host]) do |conn|
      conn.headers['Authorization-Key'] = usajobs_api_config[:authorization_key]
      conn.headers['User-Agent'] = usajobs_api_config[:user_agent]
      conn.request(:json)
      conn.response(:mrashify)
      conn.response(:json)
      conn.use(:instrumentation)
      conn.adapter(usajobs_api_config[:adapter] || Faraday.default_adapter)
    end
  end

  def self.scrub_query(query)
    query.remove(/\b#{SCRUB_KEYWORDS}\b/i).squish
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
    ((query =~ /\b#{JOB_RELATED_KEYWORDS}\b/i) && \
     (query !~ /\b#{BLOCKED_KEYWORDS}\b/i) && \
     (query !~ /["():]|^-| -\S+/))
  end

  def self.params(options)
    { Keyword: scrub_query(options[:query]),
      Organization: options[:organization_codes],
      LocationName: options[:location_name],
      ResultsPerPage: options[:results_per_page],
      Radius: SEARCH_RADIUS }
  end

end

Jobs.establish_connection!
