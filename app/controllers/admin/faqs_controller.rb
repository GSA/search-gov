class Admin::FaqsController < Admin::AdminController
  active_scaffold :faq do |config|
    config.list.per_page = 100
  end
end
