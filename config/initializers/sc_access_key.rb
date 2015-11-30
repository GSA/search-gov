sc_access_key_yml = "#{Rails.root}/config/sc_access_key.yml"
begin
  SC_ACCESS_KEY = YAML.load_file(sc_access_key_yml)[Rails.env]['secret']
rescue Exception => e
  SC_ACCESS_KEY = 'no-secret-found'
  STDERR.puts "Unable find SearchConsumer access key for environment #{Rails.env} in #{sc_access_key_yml}, using bogus SC_ACCESS_KEY=#{SC_ACCESS_KEY}: #{e.message}"
end
