class Admin::CatalogPrefixesController < Admin::AdminController
  active_scaffold :catalog_prefix do |config|
    config.label = 'Customer Catalog Prefix Whitelist'
  end
end
