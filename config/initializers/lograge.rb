UsasearchRails3::Application.configure do
  config.lograge.keep_original_rails_log = true
  config.lograge.enabled = true
  config.lograge.logger = ActiveSupport::BufferedLogger.new "#{Rails.root}/log/lograge_#{Rails.env}.log"
  config.lograge.custom_options = lambda do |event|
    {
      ip: event.payload[:ip],
      time: event.time.utc.iso8601
    }
  end
end
