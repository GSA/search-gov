class UserSessionsController < ApplicationController
  before_action :reset_session, only: [:destroy]
  before_action :require_user, only: :destroy

  def security_notification
    redirect_to(account_path) if current_user && current_user&.complete?
  end

  def destroy
    current_user_session.destroy
    redirect_to(login_path)
  end
end
