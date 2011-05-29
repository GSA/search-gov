class Affiliates::ApiController < Affiliates::AffiliatesController
  before_filter :require_affiliate_or_admin
  before_filter :setup_affiliate

  def index
  end

end
