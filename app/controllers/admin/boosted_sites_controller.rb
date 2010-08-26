class Admin::BoostedSitesController < Admin::AdminController
  active_scaffold :boosted_site do |config|
    config.actions.exclude :create, :update
    config.list.per_page = 100
  end
end