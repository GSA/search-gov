class Admin::BoostedSitesController < Admin::AdminController
  before_filter :require_affiliate_admin

  active_scaffold :boosted_site
end