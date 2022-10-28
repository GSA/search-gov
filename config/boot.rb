ENV['BUNDLE_GEMFILE'] ||= File.expand_path('../Gemfile', __dir__)

require "bundler/setup" # Set up gems listed in the Gemfile.
if Rails.env.development? || Rails.env.test?
  require "bootsnap/setup"
end