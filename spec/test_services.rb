module TestServices
  extend self

  REDIS_TEST_PID = "#{Rails.root}/tmp/pids/redis-test.pid".freeze
  REDIS_CACHE_PATH = "#{Rails.root}/tmp/cache".freeze
  REDIS_PIDS_PATH = "#{Rails.root}/tmp/pids".freeze
  TEST_DUMP_RDB = 'dump.rdb'.freeze

  def start_redis
    Dir.mkdir(REDIS_CACHE_PATH) unless File.directory?(REDIS_CACHE_PATH)
    Dir.mkdir(REDIS_PIDS_PATH) unless File.directory?(REDIS_PIDS_PATH)
    redis_options = {
        'daemonize' => 'yes',
        'pidfile' => REDIS_TEST_PID,
        'port' => 6380,
        'timeout' => 300,
        'save 900' => 1,
        'save 300' => 10,
        'save 60' => 10000,
        'dbfilename' => TEST_DUMP_RDB,
        'dir' => REDIS_CACHE_PATH,
        'loglevel' => 'debug',
        'logfile' => "stdout",
        'databases' => 16
    }.map { |k, v| "#{k} #{v}" }.join("\n")
    `echo '#{redis_options}' | redis-server -`
  end

  def stop_redis
    %x{
      cat #{REDIS_TEST_PID} | xargs kill -9
      rm -f #{REDIS_CACHE_PATH}/#{TEST_DUMP_RDB}
    }
  end

end
