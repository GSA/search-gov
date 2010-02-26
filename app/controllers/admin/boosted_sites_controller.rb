class Admin::BoostedSitesController < Admin::AdminController
  active_scaffold :boosted_site do |config|
    config.actions.exclude :create, :update
  end
end