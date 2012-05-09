class ClickedController < ActionController::Metal
  include ActionController::Rendering
  include ActionController::Instrumentation

  def index
    unless params['u'].blank?
      url = CGI.unescape(params['u']).gsub(' ', '+')
      query = params['q']
      position = params['p']
      queried_at = Time.at(params['t'].to_i)
      queried_at_gmt = queried_at.getgm.to_formatted_s(:db)
      affiliate_name = params['a'].blank? ? nil : params['a']
      results_source = params['s']
      vertical = params['v']
      locale = params['l']
      click_ip = env['REMOTE_ADDR']
      user_agent = env['HTTP_USER_AGENT']

      Click.log(url, query, queried_at_gmt, click_ip, affiliate_name, position, results_source, vertical, locale, user_agent)
    end
    self.response_body = ""
  end
end
