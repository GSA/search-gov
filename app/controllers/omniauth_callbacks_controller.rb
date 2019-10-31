# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def login_dot_gov
    auth = request.env['omniauth.auth']
    @user = User.from_omniauth(auth)

    if @user.persisted? && @user.approval_status != 'not_approved'
      reset_session
      set_user_session

      redirect_to(admin_home_page_path)
    else
      redirect_to('https://search.gov/access-denied')
    end
  end

  private

  def set_user_session
    user_session = UserSession.create(@user)
    user_session.secure = Rails.application.config.ssl_options[:secure_cookies]
  end
end