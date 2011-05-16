class ClickedController < ActionController::Metal
  def index
    Rails.logger.silence do
      Click.create(:url => CGI.unescape(params['u']).gsub(' ', '+'),
                   :query => params['q'],
                   :serp_position => params['p'],
                   :queried_at => Time.at(params['t'].to_i),
                   :affiliate => params['a'].blank? ? nil : params['a'],
                   :results_source => params['s'],
                   :clicked_at => DateTime.now,
                   :click_ip => env['REMOTE_ADDR'],
                   :user_agent => env['HTTP_USER_AGENT']) unless params['u'].blank?
      self.response_body = ""
    end
  end
end
