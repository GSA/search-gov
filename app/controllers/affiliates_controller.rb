class AffiliatesController < ApplicationController
  def index
    @affiliates = Affiliate.all
  end
end
