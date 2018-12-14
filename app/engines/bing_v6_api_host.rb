module BingV6ApiHost
  API_HOST = 'https://www.bingapis.com'.freeze

  def self.included(base)
    def base.api_host
      API_HOST
    end
  end
end
