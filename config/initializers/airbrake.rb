require 'airbrake'
config = Rails.application.secrets.airbrake

Airbrake.configure do |c|
  c.project_id = config[:project_id]
  c.project_key = config[:project_key]
  c.root_directory = Rails.root
  c.logger = Rails.logger
  c.environment = Rails.env
  c.ignore_environments = %w(test)
  c.blacklist_keys = [:password, :password_confirmation]
end if config[:enabled]

(config[:ignore] || []).each do |error_klass|
  Airbrake.add_filter do |notice|
    if notice[:errors].any? { |error| error[:type] == error_klass }
      notice.ignore!
    end
  end
end
