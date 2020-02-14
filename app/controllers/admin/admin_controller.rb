# frozen_string_literal: true

class Admin::AdminController < ApplicationController
  newrelic_ignore
  layout 'admin'
  include Accountable

  before_action :require_affiliate_admin
  before_action :check_user_account_complete

  ActiveScaffold.set_defaults do |config|
    config.list.per_page = 100
  end

  private

  def require_affiliate_admin
    return false if require_user == false
    unless current_user.is_affiliate_admin?
      redirect_to account_path
      return false
    end
  end
end
