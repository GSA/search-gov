begin
  require 'sauce/raketasks'
rescue LoadError => e
  $stderr.puts e.message
end

# saucelabs configuration:
# gem install sauce
# sauce configure  usa_search 5060039c-fa2b-403c-9fef-617142894173
