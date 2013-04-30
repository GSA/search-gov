require 'simplecov'
require 'simplecov-rcov'
SimpleCov.formatter = SimpleCov::Formatter::RcovFormatter

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec'
require 'rspec/rails'
require 'remarkable'
require 'remarkable_activerecord'
require "email_spec"
require "authlogic/test_case"
require 'webrat'
require 'sunspot/rails/spec_helper'
require 'paperclip/matchers'
require 'rspec/autorun'

include Authlogic::TestCase

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
  #config.order = 'random'

  REDIS_PID = "#{Rails.root}/tmp/pids/redis-test.pid"
  REDIS_CACHE_PATH = "#{Rails.root}/tmp/cache/"

  config.before(:suite) do
    Dir.mkdir("#{Rails.root}/tmp/cache") unless File.directory?("#{Rails.root}/tmp/cache")
    Dir.mkdir("#{Rails.root}/tmp/pids") unless File.directory?("#{Rails.root}/tmp/pids")
    redis_options = {
      "daemonize" => 'yes',
      "pidfile" => REDIS_PID,
      "port" => 6380,
      "timeout" => 300,
      "dbfilename" => "dump.rdb",
      "dir" => REDIS_CACHE_PATH,
      "loglevel" => "debug",
      "logfile" => "stdout",
      "databases" => 16
    }.map { |k, v| "#{k} #{v}" }.join("\n")
    `echo '#{redis_options}' | redis-server -`

    EmailTemplate.load_default_templates
  end

  config.before(:each) do
    common = '/json.aspx?Adult=moderate&AppId=A4C32FAE6F3DB386FC32ED1C4F3024742ED30906&sources=Spell+Image&'
    hl='Options=EnableHighlighting&'
    stubs = Faraday::Adapter::Test::Stubs.new
    generic_bing_image_result = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/image_search/white_house.json")
    stubs.get("#{common}#{hl}query=white+house") { [200, {}, generic_bing_image_result] }
    stubs.get("#{common}#{hl}query=%28white+house%29+%28site%3Anonsense.gov%29") { [200, {}, generic_bing_image_result] }
    bing_image_no_result = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/image_search/no_results.json")
    stubs.get("#{common}#{hl}query=%28unusual+image%29+%28site%3Anonsense.gov%29") { [200, {}, bing_image_no_result] }

    common = '/json.aspx?Adult=moderate&AppId=A4C32FAE6F3DB386FC32ED1C4F3024742ED30906&sources=Spell+Web&'
    generic_bing_result = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/ira.json")
    stubs.get("#{common}#{hl}query=highlight+enabled") { [200, {}, generic_bing_result] }
    generic_bing_result_no_highlight = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/ira_no_highlight.json")
    stubs.get("#{common}query=no+highlighting&web.offset=11") { [200, {}, generic_bing_result_no_highlight] }
    stubs.get("#{common}#{hl}query=casa+blanca") { [200, {}, generic_bing_result] }
    stubs.get("#{common}#{hl}query=english") { [200, {}, generic_bing_result] }
    stubs.get("#{common}#{hl}query=%28english%29+%28site%3Anonsense.gov%29") { [200, {}, generic_bing_result] }

    page2_6results = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/page2_6results.json")
    stubs.get("#{common}#{hl}query=%28fewer%29+%28site%3Anonsense.gov%29&web.offset=11") { [200, {}, page2_6results] }

    total_no_results = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/total_no_results.json")
    stubs.get("#{common}#{hl}query=total_no_results") { [200, {}, total_no_results] }

    two_results_1_missing_title = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/2_results_1_missing_title.json")
    stubs.get("#{common}#{hl}query=2missing1") { [200, {}, two_results_1_missing_title] }

    missing_descriptions = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/missing_descriptions.json")
    stubs.get("#{common}#{hl}query=missing_descriptions") { [200, {}, missing_descriptions] }

    bing_no_results = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/no_results.json")
    stubs.get("#{common}#{hl}query=no_results") { [200, {}, bing_no_results] }
    stubs.get("#{common}#{hl}query=%28no_results%29+%28site%3Anonsense.gov%29") { [200, {}, bing_no_results] }

    bing_spelling = File.read(Rails.root.to_s + "/spec/fixtures/json/bing/web_search/spelling_suggestion.json")
    stubs.get("#{common}#{hl}query=electro+coagulation") { [200, {}, bing_spelling] }

    common = '/customsearch/v1?alt=json&key=AIzaSyAqgqnBqdXKtLfmEEzarf96hlnzD5koi34&cx=015426204394000049396:9fkj8sbnfpi&searchType=image&quotaUser=USASearch'
    common_params = '&lr=lang_en&safe=medium'
    generic_google_image_result = File.read(Rails.root.to_s + "/spec/fixtures/json/google/image_search/obama.json")
    stubs.get("#{common}#{common_params}&q=obama") { [200, {}, generic_google_image_result] }

    common = '/customsearch/v1?alt=json&key=AIzaSyAqgqnBqdXKtLfmEEzarf96hlnzD5koi34&cx=015426204394000049396:9fkj8sbnfpi&quotaUser=USASearch'
    generic_google_result = File.read(Rails.root.to_s + "/spec/fixtures/json/google/web_search/ira.json")
    stubs.get("#{common}#{common_params}&q=highlight+enabled") { [200, {}, generic_google_result] }
    stubs.get("#{common}#{common_params}&q=no+highlighting") { [200, {}, generic_google_result] }
    stubs.get("#{common}&lr=lang_es&safe=medium&q=casa+blanca") { [200, {}, generic_google_result] }
    stubs.get("#{common}#{common_params}&q=english") { [200, {}, generic_google_result] }

    google_no_results = File.read(Rails.root.to_s + "/spec/fixtures/json/google/web_search/no_results.json")
    stubs.get("#{common}#{common_params}&q=no_results") { [200, {}, google_no_results] }

    google_spelling = File.read(Rails.root.to_s + "/spec/fixtures/json/google/web_search/spelling_suggestion.json")
    stubs.get("#{common}#{common_params}&q=electro+coagulation") { [200, {}, google_spelling] }

    test = Faraday.new do |builder|
      builder.adapter :test, stubs
      builder.response :rashify
      builder.response :json
    end

    #FIXME: this is in here just to get rcov coverage on SearchApiConnection
    params = {affiliate: 'wh', index: 'web', query: 'obama'}
    SearchApiConnection.new('myapi', 'http://search.usa.gov').get('/api/search.json', params)

    Faraday.stub!(:new).and_return test
  end

  config.after(:suite) do
    %x{
      cat #{REDIS_PID} | xargs kill -9
      rm -f #{REDIS_CACHE_PATH}dump.rdb
    }
  end

end

Webrat.configure do |config|
  config.mode = :rails
end