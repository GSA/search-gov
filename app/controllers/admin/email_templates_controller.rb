class Admin::EmailTemplatesController < Admin::AdminController
  active_scaffold :email_template do |config|
    config.columns = [:name, :subject, :body, :created_at, :updated_at]
  end
end
