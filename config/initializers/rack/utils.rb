module Rack
  module Utils
    def unescape(s, encoding = Encoding::UTF_8)
      URI.decode_www_form_component(s, encoding)
    rescue ArgumentError
      s
    end
    module_function :unescape
  end
end