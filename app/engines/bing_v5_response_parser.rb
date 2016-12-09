class BingV5ResponseParser
  attr_reader :engine
  attr_reader :bing_response

  def initialize(engine, bing_response)
    @engine = engine
    @bing_response = bing_response
  end

  def parsed_response
    raise response_error_message if response_error_message

    response = CommercialSearchEngineResponse.new

    response.spelling_suggestion = spelling_suggestion
    response.results = results
    response.start_record = start_record
    response.end_record = end_record
    response.next_offset = next_offset
    response.total = total
    response.tracking_information = tracking_information

    response
  end

  protected

  def bing_response_body
    @bing_response_body ||= Hashie::Mash.new(bing_response.body.reverse_merge(default_bing_response_parts))
  end

  def response_error_message
    "received status code #{bing_response_body.status_code} - #{bing_response_body.message}" if bing_response_body.status_code != 200
  end

  def start_record
    @start_record ||= engine.params[:offset] + 1
  end

  def end_record
    start_record + results.size - 1
  end

  def spelling_suggestion
    bing_response_body.query_context.altered_query
  end

  def next_offset
    offset = engine.params[:offset] + engine.params[:count]
    offset >= total ? nil : offset
  end

  def tracking_information
    bing_response.headers['BingAPIs-TraceId']
  end
end
