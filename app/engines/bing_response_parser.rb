class BingResponseParser
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

  def default_bing_response_parts
    {
      _type: nil,
      errors: [{ message: nil }],
      query_context: { },
      status_code: 200,
    }
  end

  def response_error_message
    if bing_response_body.status_code != 200
      "received status code #{bing_response_body.status_code} - #{bing_response_body.message}"
    elsif bing_response_body._type == 'ErrorResponse'
      bing_response_body.errors.first.message
    end
  end

  def start_record
    @start_record ||= engine.params[:offset] + 1
  end

  def end_record
    start_record + results.size - 1
  end

  def spelling_suggestion
    nil
  end

  def next_offset
    offset = engine.params[:offset] + engine.params[:count]
    offset >= total ? nil : offset
  end

  def tracking_information
    bing_response.headers['BingAPIs-TraceId']
  end
end
