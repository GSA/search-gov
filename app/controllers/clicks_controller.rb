class ClicksController < ApplicationController
  def create
    Click.create(:url => params['u'],
                 :query => params['q'],
                 :serp_position => params['p'],
                 :queried_at => Time.at(params['t'].to_i),
                 :affiliate => params['a'].present? ? params['a'] : nil,
                 :results_source => params['s'],
                 :clicked_at => DateTime.now,
                 :click_ip => request.env['REMOTE_ADDR'],
                 :user_agent => request.user_agent)
    render :nothing => true
  end
end

