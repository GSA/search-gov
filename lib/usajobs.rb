module Usajobs
  JOB_RELATED_KEYWORDS = '((position|job|opening|posting|employment)s?|(opportunit|vacanc)(y|ies))'

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
      conn.response :caching do
        ActiveSupport::Cache::FileStore.new File.join(Rails.root, 'tmp', 'cache'), {:namespace => 'usajobs_api', :expires_in => 86400}
      end
      conn.use :instrumentation
      conn.adapter usajobs_api_config['adapter'] || Faraday.default_adapter
    end
  end

  def self.search(options)
    @usajobs_api_connection.get(@endpoint, options).body  if options[:query] =~ /\b#{JOB_RELATED_KEYWORDS}\b/i
  rescue Exception => e
    Rails.logger.error("Trouble fetching USAJobs information: #{e}")
    nil
  end
end

Usajobs.establish_connection!