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

  def create_es_indexes
    Dir[Rails.root.join('app/models/elastic_*.rb').to_s].each do |filename|
      klass = File.basename(filename, '.rb').camelize.constantize
      klass.recreate_index if klass.kind_of?(Indexable) and klass != ElasticBlended
    end
    logstash_index_range.each do |date|
      ES::CustomIndices.client_reader.indices.delete(index: "logstash-#{date.strftime("%Y.%m.%d")}") rescue Elasticsearch::Transport::Transport::Errors::NotFound
      ES::CustomIndices.client_reader.indices.create(index: "logstash-#{date.strftime("%Y.%m.%d")}")
      ES::CustomIndices.client_reader.indices.put_alias(index: "logstash-#{date.strftime("%Y.%m.%d")}", name: "human-logstash-#{date.strftime("%Y.%m.%d")}")
    end
  end

  def delete_es_indexes
    ES::CustomIndices.client_reader.indices.delete(index: "test-usasearch-*")
    ES::CustomIndices.client_reader.indices.delete(index: "test-i14y-*")
    logstash_index_range.each do |date|
      ES::CustomIndices.client_reader.indices.delete(index: "logstash-#{date.strftime("%Y.%m.%d")}")
    end
  rescue Exception => e
  end

  def logstash_index_range
    end_date = Date.current
    start_date = end_date - 10.days
    start_date..end_date
  end
end
