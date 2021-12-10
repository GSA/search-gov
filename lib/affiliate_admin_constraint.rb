# frozen_string_literal: true

require 'authlogic/controller_adapters/sinatra_adapter'

class AffiliateAdminConstraint
  def self.matches?(request)
    Authlogic::Session::Base.controller =
      Authlogic::ControllerAdapters::SinatraAdapter::Adapter.new(request)
    user_session = UserSession.find
    user_session&.user&.is_affiliate_admin?
  end
end
