module Usajobs
  JOB_RELATED_KEYWORDS = '((position|job|opening|posting|employment)s?|(opportunit|vacanc)(y|ies))'
  BLOCKED_KEYWORDS = 'descriptions?'

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
      @usajobs_api_connection.get(@endpoint, options).body
    end
  rescue Exception => e
    Rails.logger.error("Trouble fetching USAJobs information: #{e}")
    nil
  end

  def self.query_eligible?(query)
    query =~ /\b#{JOB_RELATED_KEYWORDS}\b/i && !(query =~ /\b#{BLOCKED_KEYWORDS}\b/i)
  end
end

Usajobs.establish_connection!