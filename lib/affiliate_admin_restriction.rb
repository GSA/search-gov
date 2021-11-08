# frozen_string_literal: true

require 'sinatra'
require "authlogic/controller_adapters/sinatra_adapter"

class AffiliateAdminRestriction
  def self.matches?(request)
    Authlogic::Session::Base.controller =
      Authlogic::ControllerAdapters::SinatraAdapter::Adapter.new(request)
    user_session = UserSession.find
    user_session && user_session.user.is_affiliate_admin?
  end
end
