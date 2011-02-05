begin
  require 'sauce/raketasks'
rescue LoadError => e
  $stderr.puts e.message
end

# saucelabs configuration:
# gem install sauce
# sauce configure  irrationaldesign 62285eaf-f008-4eae-b70e-9231856d219e
