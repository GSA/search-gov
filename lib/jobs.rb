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
    jobs_api_config = Rails.application.secrets.jobs
    @endpoint = jobs_api_config['endpoint']
    @jobs_api_connection = Faraday.new jobs_api_config['host'] do |conn|
      conn.request :json
      conn.response :mashify
      conn.response :json
      conn.use :instrumentation
      conn.adapter jobs_api_config['adapter'] || Faraday.default_adapter
    end
    @jobs_api_connection.headers[:accept] = 'application/vnd.usagov.position_openings.v3'
  end

  def self.search(options)
    @jobs_api_connection.get(@endpoint, options).body if query_eligible?(options[:query])
  rescue Exception => e
    Rails.logger.error("Trouble fetching jobs information: #{e}")
    nil
  end

  def self.query_eligible?(query)
    query =~ /\b#{JOB_RELATED_KEYWORDS}\b/i && !(query =~ /\b#{BLOCKED_KEYWORDS}\b/i) && !(query =~ /["():]|^-| -\S+/)

  end

end

Jobs.establish_connection!
