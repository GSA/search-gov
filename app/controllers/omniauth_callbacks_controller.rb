# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController

  def login_dot_gov
    @user = User.from_omniauth(request.env['omniauth.auth'])
    return unless @user.persisted?

    UserSession.create(@user)
    redirect_to(admin_home_page_path)
  end

  #def failure
  #  flash[:notice] = "Sorry, You didn't authorize"
  #  redirect_to root_url
  #end

  #def destroy
  #  @authorization = current_user.authorizations.find(params[:id])
  #  flash[:notice] = "Successfully deleted #{@authorization.provider} authentication."
  #  @authorization.destroy
  #  redirect_to edit_user_path(:current)
  #end
end