# frozen_string_literal: true

module Api
  module V2
    class ClickController < ClickedController
      private

      def click_class
        ApiClick
      end

      def permitted_params
        super.merge(params.permit(:access_key))
      end

      def invalid_click_status
        if click.errors.full_messages.include? 'Access key is invalid'
          :unauthorized
        else
          :bad_request
        end
      end
    end
  end
end
