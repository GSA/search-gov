require 'simplecov'
SimpleCov.command_name 'RSpec'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec/rails'
require 'rspec/json_expectations'
require 'email_spec'
require 'authlogic/test_case'
require 'webrat'
require 'paperclip/matchers'
require 'rspec/autorun'
require 'webmock/rspec'

include Authlogic::TestCase
WebMock.disable_net_connect!(allow_localhost: true)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join("spec/support/**/*.rb")].each { |f| require f }

# figure out where we are being loaded from to ensure it's only done once
if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
  begin
    raise "foo"
  rescue => e
    puts <<-MSG
  ===================================================
  It looks like spec_helper.rb has been loaded
  multiple times. Normalize the require to:

    require "spec/spec_helper"

  Things like File.join and File.expand_path will
  cause it to be loaded multiple times.

  Loaded this time from:

    #{e.backtrace.join("\n    ")}
  ===================================================
    MSG
  end
end

RSpec.configure do |config|
  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.include Paperclip::Shoulda::Matchers
  config.treat_symbols_as_metadata_keys_with_true_values = true

  # This prevents affiliate-related tests from failing with an empty test db
  # if the language fixtures haven't been loaded in a prior test. One *should* be
  # able to do that using an association in the fixture, but fixture associations
  # do NOT play nicely with our custom, string primary key 'code' in the language table
  config.global_fixtures = [:languages]

  config.before(:suite) do
    FileUtils.mkdir_p(File.join(Rails.root.to_s, 'tmp'))

    require 'test_services'
    unless ENV['TRAVIS']
      TestServices::start_redis
    end

    EmailTemplate.load_default_templates
    OutboundRateLimit.load_defaults
    TestServices::delete_es_indexes
    TestServices::create_es_indexes

  end

  config.before(:each) do
    i14y_api_url = "#{I14yCollections.host}#{I14yCollections::API_ENDPOINT}/search?"
    i14y_web_result = Rails.root.join('spec/fixtures/json/i14y/web_search/marketplace.json').read
    i14y_search_params = { handles: 'one,two', language: 'en', offset: 0, query: 'marketplase', size: 20 }
    stub_request(:get, "#{i14y_api_url}#{i14y_search_params.to_param}").
      to_return( status: 200, body: i14y_web_result )
  end

  config.after(:suite) do
    TestServices::delete_es_indexes
    TestServices::stop_redis unless ENV['TRAVIS']
  end

  # Add VCR to all tests
  config.around(:each) do |example|
    options = example.metadata[:vcr] || {}
    if options[:record] == :skip
      VCR.turn_off!(ignore_cassettes: true)
      example.run
      VCR.turn_on!
    else
      description = example.metadata[:full_description]
      test = example.metadata[:description_args][0].to_s
      full_context = description.chomp(test).strip
      name = full_context.split(/\s+/, 2).join('/').underscore.gsub(/\./,'/').gsub(/[^\w\/]+/, '_').gsub(/\/$/, '')
      VCR.use_cassette(name, options, &example)
    end
  end
end

Webrat.configure do |config|
  config.mode = :rails
end


