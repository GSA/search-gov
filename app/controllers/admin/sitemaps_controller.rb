class Admin::SitemapsController < Admin::AdminController
  active_scaffold :sitemap do |config|
    config.label = "Sitemaps"
    config.actions = [:create, :delete, :list]
    config.columns = [:url, :created_at, :updated_at]
    config.create.columns = [:url]
    config.create.link.label = "Create Sitemap"
    config.delete.link.confirm = "Are you sure you want to delete this sitemap?"
  end
end