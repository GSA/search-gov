module FaradayResponseBodyRashify
  def self.process_response(response)
    body = case response.body
           when Hash
             parse response.body
           when String
             parse ::JSON.parse(response.body)
    end
    response.env.body = body if body
  end

  def self.parse(body)
    case body
    when Hash
      Hashie::Mash::Rash.new body
    when Array
      body.map { |item| parse(item) }
    else
      body
    end
  end
end
