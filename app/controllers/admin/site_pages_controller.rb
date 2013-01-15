class Admin::SitePagesController < Admin::AdminController
  active_scaffold :site_page do |config|
    config.label = 'USA.gov Mobile'
  end
end