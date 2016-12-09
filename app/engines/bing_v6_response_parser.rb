class BingV6ResponseParser < BingV5ResponseParser

  protected

  def response_error_message
    bing_response_body.errors.first.message if bing_response_body._type == 'ErrorResponse'
  end
end
