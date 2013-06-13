class Admin::SiteDomainsController < Admin::AdminController
  active_scaffold :site_domain do |config|
    config.actions.exclude :show, :create, :update
  end
end
