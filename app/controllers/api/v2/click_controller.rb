# frozen_string_literal: true

module Api
  module V2
    class ClickController < ApplicationController
      def create
        click = ApiClick.new(click_params)

        if click.valid?
          click.log
          head :ok
        else
          render json: click.errors.full_messages, status: status(click)
        end
      end

      private

      def click_params
        permitted = params.permit(:url, :query, :position,
                                  :module_code, :affiliate, :vertical,
                                  :client_ip, :user_agent, :access_key)
        permitted.to_hash.symbolize_keys
      end

      def status(click)
        if click.errors.full_messages.include? 'Access key is invalid'
          :unauthorized
        else
          :bad_request
        end
      end
    end
  end
end
