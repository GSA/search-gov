class Admin::SiteDomainsController < Admin::AdminController
  active_scaffold :site_domains do |config|
    config.actions.exclude :show, :create, :update
  end
end
