class ResponseData < Hash
  private
  def initialize(data={})
    data.each_pair {|k, v| self[k.to_s] = deep_parse(v) }
  end

  def deep_parse(data)
    case data
      when Hash
        self.class.new(data)
      when Array
        data.map {|v| deep_parse(v) }
      else
        data
    end
  end

  def method_missing(*args)
    name = args[0].to_s
    return self[name] if has_key? name
    camelname = name.split('_').map {|w| "#{w[0, 1].upcase}#{w[1..-1]}" }.join("")
    if has_key? camelname
      self[camelname]
    else
      super *args
    end
  end
end