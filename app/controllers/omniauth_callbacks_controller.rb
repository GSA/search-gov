# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def login_dot_gov
    @user = User.from_omniauth(request.env['omniauth.auth'])
    if @user.persisted? && @user.approval_status != 'not_approved'
      reset_session
      set_user_session

      if @user.complete?
        redirect_to(admin_home_page_path)
      else
        redirect_to(
          edit_account_path,
          flash: {
            error:
              'Please complete your registration. Make sure Name and '\
              'Government agency are not empty'
          }
        )
      end
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
