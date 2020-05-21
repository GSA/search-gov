# frozen_string_literal: true

class ClickedController < ApplicationController
  before_action :check_required_params

  def index
    url = CGI.unescape(params['u']).gsub(' ', '+') rescue nil
    query = params['q']
    position = params['p']
    affiliate_name = params['a'].presence
    results_source = params['s']
    vertical = params['v']
    click_ip = request.env['REMOTE_ADDR']
    user_agent = request.env['HTTP_USER_AGENT']
    Click.log(url, query, click_ip, affiliate_name, position, results_source, vertical, user_agent)

    head :ok
  end

  private

  def check_required_params
    # Error messages to match activemodels, used in the rest of the api
    errors = []
    errors << 'url must be present' if params[:u].blank?
    errors << 'query must be present' if params[:q].blank?
    errors << 'position must be present' if params[:p].blank?
    errors << 'source must be present' if params[:s].blank?
    render json: { errors: errors }.to_json, status: :bad_request if errors.present?
  end
end
