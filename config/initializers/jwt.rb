jwt_yml = "#{Rails.root}/config/jwt.yml"
begin
  JWT_SECRET = YAML.load_file(jwt_yml)[Rails.env]['secret']
rescue Exception => e
  JWT_SECRET = 'no-secret-found'
  STDERR.puts "Unable find JWT secret for environment #{Rails.env} in #{jwt_yml}, using bogus JWT_SECRET=#{JWT_SECRET}: #{e.message}"
end
