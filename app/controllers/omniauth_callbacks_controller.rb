# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController
  def login_dot_gov
    auth = request.env['omniauth.auth']
    @user = User.from_omniauth(auth)
    return unless @user.persisted?

    update_uid(@user)
    UserSession.create(@user)
    redirect_to(admin_home_page_path)
  end

  private

  def update_uid(user)
    return if user.uid.present?

    user.uid = auth.uid
    user.save!
  end
end