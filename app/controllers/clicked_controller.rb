class ClickedController < ActionController::Metal
  def index
    url = CGI.unescape(params['u']).gsub(' ', '+') rescue nil
    if url.present?
      query = params['q']
      position = params['p']
      queried_at = Time.at(params['t'].to_i)
      queried_at_gmt = queried_at.getgm.to_formatted_s(:db)
      affiliate_name = params['a'].blank? ? nil : params['a']
      results_source = params['s']
      vertical = params['v']
      locale = params['l']
      click_ip = request.env['REMOTE_ADDR']
      user_agent = request.env['HTTP_USER_AGENT']
      model_id = params['i']
      Click.log(url, query, queried_at_gmt, click_ip, affiliate_name, position, results_source, vertical, locale, user_agent, model_id)
    end
    self.response_body = ""
  end
end
