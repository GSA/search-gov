class ClickedController < ActionController::Metal
  def index
    url = CGI.unescape(params['u']).gsub(' ', '+') rescue nil
    if url.present?
      query = params['q']
      position = params['p']
      affiliate_name = params['a'].blank? ? nil : params['a']
      results_source = params['s']
      vertical = params['v']
      click_ip = request.env['REMOTE_ADDR']
      user_agent = request.env['HTTP_USER_AGENT']
      Click.log(url, query, click_ip, affiliate_name, position, results_source, vertical, user_agent)
    end
    self.response_body = ""
  end
end
