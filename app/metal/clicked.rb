# Allow the metal piece to run in isolation
require(File.dirname(__FILE__) + "/../../config/environment") unless defined?(Rails)

class Clicked
  def self.call(env)
    if env["PATH_INFO"] =~ /^\/clicked/
      params = Rack::Request.new(env).params
      Click.create(:url => CGI.unescape(params['u']).gsub(' ', '+'),
                   :query => params['q'],
                   :serp_position => params['p'],
                   :queried_at => Time.at(params['t'].to_i),
                   :affiliate => params['a'].blank? ? nil : params['a'],
                   :results_source => params['s'],
                   :clicked_at => DateTime.now,
                   :click_ip => env['REMOTE_ADDR'],
                   :user_agent => env['HTTP_USER_AGENT']) unless params['u'].blank? 
      [200, {"Content-Type" => "text/html"}, ['']]
    else
      [404, {"Content-Type" => "text/html"}, ["Not Found"]]
    end
  end
end
