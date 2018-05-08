namespace :usasearch do
  desc "Update customer-provided links to https where possible"
  # Usage: rake usasearch:update_https[BoostedContent,url,srsly]
  # Updates will only occur when the 'srsly' arg is included
  task :update_https, [:klass, :column, :srsly] => [:environment] do |_task, args|
    begin
      @klass = args.klass.constantize
      @column = args.column.to_sym
      @srsly = args.srsly || false
      @file = File.open('lib/tasks/secure_hosts.csv', 'a+')
      @secure_hosts = @file.readlines.map(&:strip)
      @insecure_hosts = []
      @updated_records = 0
      toggle_url_readonly(:off) if [FlickrProfile,RssFeedUrl].include?(@klass)
      @klass.where("#{@column} != '' AND #{@column} not like 'https%'").find_each do |record|
        httpsify(record)
      end
    ensure
      toggle_url_readonly(:on) if [FlickrProfile,RssFeedUrl].include?(@klass)
      report
      @file.close
    end
  end

  def httpsify(record)
    uri = Addressable::URI.heuristic_parse record.send(@column)
    uri.scheme = 'https'

    if @secure_hosts.include?(uri.host) || https_available?(uri)
      secure_url = uri.to_s
      puts "certificate validated for: #{secure_url}"
      record.update_attribute(@column, secure_url ) if @srsly
      save_host(uri.host) unless @secure_hosts.include? uri.host
      @updated_records += 1
    end
  rescue StandardError => error
    warn "Error httspify-ing #{record.class},#{record.id},#{record.send(@column)}\n#{error}".red
  end

  def https_available?(uri)
    return false if @insecure_hosts.include?(uri.host)

    normalized_site = "https://#{uri.host}"
    response = get_head(normalized_site)
    puts "status: #{response.status}"
    true
  rescue Faraday::Error => error
    warn "#{error}: #{normalized_site}".red
    @insecure_hosts << uri.host
    false
  end

  def get_head(site)
    puts "sending HEAD request for: #{site}"
    Faraday.head do |req|
      req.url(site)
      req.options.timeout = 10
      req.options.open_timeout = 10
    end
  end

  def save_host(host)
    @secure_hosts << host
    @file.puts host
  end

  def report
    puts "-----------------------------"
    if @srsly
      puts "#{@updated_records} #{@klass} records were updated".green
    else
      puts "#{@updated_records} #{@klass} records could have been be updated. To update, include the 'srsly' argument:\n'rake usasearch:update_https[#{@klass},#{@column},srsly]'"
    end
  end

  def toggle_url_readonly(status)
    if status == :on
      RssFeedUrl.class_eval { def self.readonly_attributes ; %w{ rss_feed_owner_type url } ; end }
      FlickrProfile.class_eval { def self.readonly_attributes ; %w{profile_type profile_id url} ; end }
    else
      RssFeedUrl.class_eval { def self.readonly_attributes ; %w{ rss_feed_owner_type } ; end }
      FlickrProfile.class_eval { def self.readonly_attributes ; %w{ profile_type profile_id } ; end }
    end
  end
end
