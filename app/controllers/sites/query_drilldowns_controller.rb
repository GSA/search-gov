class Sites::QueryDrilldownsController < Sites::SetupSiteController
  include CSVResponsive
  HEADER_FIELDS = ['Date', 'Time', 'Request', 'Referrer', 'Vertical', 'Modules', 'Device', 'Browser', 'OS', 'Country Code', 'Region', 'Client IP', 'User Agent']

  def show
    query = request["query"]
    end_date = request["end_date"].to_date
    start_date = request["start_date"].to_date
    sanitized_query = sanitize_for_filename(query)
    filename = [@site.name, sanitized_query, start_date, end_date].join('_')
    drilldown_query = DrilldownQuery.new(@site.name,
                                         start_date,
                                         end_date,
                                         'params.query.raw',
                                         query,
                                         'search')
    request_drilldown = RequestDrilldown.new(@current_user.sees_filtered_totals?,
                                             drilldown_query.body)
    requests = request_drilldown.docs.map { |doc| document_mapping(doc) }
    csv_response(filename, HEADER_FIELDS, requests)
  end

  private

  def sanitize_for_filename(query)
    query.gsub(' ','_')
  end

  def document_mapping(doc)
    record = []
    date_time = DateTime.parse(doc['@timestamp'])

    record << date_time.strftime("%Y-%m-%d")
    record << date_time.strftime("%H:%M:%S")
    record << doc['request']
    record << doc['referrer']
    record << doc['vertical']
    record << (doc['modules'].join(' ') rescue '')
    record << (doc['useragent']['device'] rescue '')
    record << (doc['useragent']['name'] rescue '')
    record << (doc['useragent']['os'] rescue '')
    record << (doc['geoip']['country_code2'] rescue '')
    record << (doc['geoip']['region_name'] rescue '')
    record << doc['clientip']
    record << doc['user_agent']
    record
  end
end
