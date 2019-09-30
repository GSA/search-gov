# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def login_dot_gov
    @user = User.from_omniauth(request.env['omniauth.auth'])
    return unless @user.persisted?

    UserSession.create(@user)
    redirect_to(admin_home_page_path)
  end
end