module Api
  module V2
    class ClickController < ApplicationController
      before_action :check_required_params
      before_action :valid_access_key
      respond_to :json

      def create
        clicked_url = CGI.unescape(params['clicked_url']).gsub(' ', '+') rescue nil
        query = params['query']
        position = params['position']
        affiliate = params['affiliate'].presence
        source = params['source']
        vertical = params['vertical']
        click_ip = params['click_ip']
        user_agent = params['user_agent']
        access_key = params['access_key']
        Click.log(clicked_url, query, click_ip, affiliate,
                  position, source, vertical, user_agent, access_key)

        head :ok
      end

      private

      def check_required_params
        # Error messages to match activemodels, used in the rest of the api
        errors = []
        required_params = %I[clicked_url query position source access_key]
        required_params.map do |param|
          errors << "#{param} must be present" if params[param].blank?
        end
        render json: { errors: errors }.to_json, status: :bad_request if errors.present?
      end

      def valid_access_key
        affiliate = Affiliate.find_by(name: params['affiliate'])
        if affiliate.api_access_key != params['access_key']
          render json: { errors: ['access_key is invalid'] }.to_json,
                 status: :unauthorized
        end
      end
    end
  end
end
