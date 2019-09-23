# frozen_string_literal: true

class OmniauthCallbacksController < ApplicationController

  def login_dot_gov

    @user = User.from_omniauth(request.env["omniauth.auth"])
    if @user.persisted?
      render text: request.env['omniauth.auth']
      #sign_in_and_redirect @user, event: :authentication #this will throw if @user is not activated
      #set_flash_message(:notice, :success, kind: "Facebook") if is_navigational_format?
    else
      #session["devise.facebook_data"] = request.env["omniauth.auth"]
      #redirect_to new_user_registration_url
    end
    #if current_user
    #  flash[:notice] = "Successfully added #{omniauth['provider']} authentication"
    #  #current_user.authorizations.create(provider: omniauth['provider'], uid: omniauth['uid']) #Add an auth to existing user
    #  redirect_to(edit_user_path(:current))
    #elsif @auth
    #  flash[:notice] = "Welcome back #{omniauth['provider']} user"
    #  UserSession.create(@auth.user, true)
    #  redirect_to root_url
    #else
    #  @new_auth = Authorization.create_from_omniauth_data(omniauth, current_user)
    #  flash[:notice] = "Welcome #{omniauth['provider']} user. Your account has been created."
    #  UserSession.create(@new_auth.user, true)
    #  redirect_to(root_url)
    #end
  end

  #def failure
  #  flash[:notice] = "Sorry, You didn't authorize"
  #  redirect_to root_url
  #end

  #def blank
  #  render :text => "Not Found", :status => 404
  #end

  #def destroy
  #  @authorization = current_user.authorizations.find(params[:id])
  #  flash[:notice] = "Successfully deleted #{@authorization.provider} authentication."
  #  @authorization.destroy
  #  redirect_to edit_user_path(:current)
  #end
end