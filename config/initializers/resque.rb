Resque.logger = Logger.new(Rails.root.join('log', 'resque.log'))
Resque.logger.level = Logger::INFO