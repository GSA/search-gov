def login(user)
  Rails.application.env_config['omniauth.auth'] = mock_user_auth(user.email)
  visit '/auth/logindotgov/callback'
end

def read_fixture_file(path)
  File.read("#{Rails.root}/spec/fixtures#{path}")
end

def open_fixture_file(path)
  File.open("#{Rails.root}/spec/fixtures#{path}")
end

def quiet_puts
  $stdout.stub(:write)
  $stderr.stub(:write)
end
