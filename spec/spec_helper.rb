require 'simplecov'
SimpleCov.command_name 'RSpec'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV['RAILS_ENV'] ||= 'test'
require File.expand_path('../../config/environment', __FILE__)
require 'rspec/rails'
require 'email_spec'
require 'authlogic/test_case'
require 'paperclip/matchers'
require 'webmock/rspec'

include Authlogic::TestCase
WebMock.disable_net_connect!(allow_localhost: true)

# Requires supporting ruby files with custom matchers and macros, etc,
# in spec/support/ and its subdirectories.
Dir[Rails.root.join('spec/support/**/*.rb')].each { |f| require f }

# figure out where we are being loaded from to ensure it's only done once
if $LOADED_FEATURES.grep(/spec\/spec_helper\.rb/).any?
  begin
    raise 'foo'
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
  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = :random

  # Seed global randomization in this process using the `--seed` CLI option.
  # Setting this allows you to use `--seed` to deterministically reproduce
  # test failures related to randomization by passing the same `--seed` value
  # as the one that triggered the failure.
  Kernel.srand config.seed

  config.mock_with :rspec
  config.fixture_path = "#{::Rails.root}/spec/fixtures"
  config.file_fixture_path = "#{::Rails.root}/spec/fixtures"
  config.use_transactional_fixtures = true
  config.include Paperclip::Shoulda::Matchers
  config.include ActiveSupport::Testing::TimeHelpers
  config.infer_spec_type_from_file_location!
  config.expect_with(:rspec) do |c|
    c.syntax = [:expect]
  end

  # Create all fixtures in spec/fixtures/*.yml for all tests in alphabetical order.
  config.global_fixtures = :all

  config.before(:suite) do
    FileUtils.mkdir_p(File.join(Rails.root.to_s, 'tmp'))

    require 'test_services'

    TestServices.verify_xpack_license
    EmailTemplate.load_default_templates
    OutboundRateLimit.load_defaults
    TestServices.delete_es_indexes
    TestServices.create_es_indexes
  end

  config.before(:each) do
    # Hitting the production I14y API during tests is unsafe, and we currently
    # lack a straightforward way to set up a dev i14y sandbox. So for very basic
    # tests, we're stubbing two sample responses - one containing facet fields
    # (SRCH-3738) and one not.
    # As we expand i14y searching options/functionality, a less opaque approach
    # to stubbing/calling this test data should be implemented, but this gets us
    # what we need for the time being with minimal changes.
    # See also: features/step_definitions/search_steps.rb
    i14y_api_url = "#{I14y.host}#{I14yCollections::API_ENDPOINT}/search?"
    i14y_result = Rails.root.join('spec/fixtures/json/i14y/marketplace.json').read
    i14y_facet_result = Rails.root.join('spec/fixtures/json/i14y/faq.json').read
    i14y_search_params = { handles: 'one,two',
                           language: 'en',
                           offset: 0,
                           query: 'marketplase',
                           size: 20 }
    # SRCH-3738: This mirrors the i14y request sent when 'include_facets = true'.
    # See: app/models/i14y_search.rb
    i14y_facet_search_params = { handles: 'one,two',
                                 language: 'en',
                                 offset: 0,
                                 query: 'faq',
                                 size: 20,
                                 include: "title,path,thumbnail,#{I14ySearch::FACET_FIELDS.join(',')}" }
    # Avoid making unnecessary requests to test domains
    stub_request(:get, /(agency|foo|searchgov)\.gov/).
      to_return(body: 'a stubbed web page')
    stub_request(:get, "#{i14y_api_url}#{i14y_search_params.to_param}").
      to_return(status: 200, body: i14y_result)
    stub_request(:get, "#{i14y_api_url}#{i14y_facet_search_params.to_param}").
      to_return(status: 200, body: i14y_facet_result)
    OmniAuth.config.mock_auth[:default] = OmniAuth::AuthHash.new({})
  end

  config.after(:each) do
    ApplicationJob.queue_adapter.enqueued_jobs.clear
    ActiveJob::Uniqueness.unlock!
  end

  config.after(:suite) do
    TestServices.delete_es_indexes
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

  config.include OmniauthHelpers
end

Shoulda::Matchers.configure do |config|
  config.integrate do |with|
    with.test_framework :rspec
    with.library :rails
  end
end

RSpec::Matchers.define_negated_matcher :have_not_enqueued_job, :have_enqueued_job
