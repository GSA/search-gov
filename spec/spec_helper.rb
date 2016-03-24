require 'codeclimate-test-reporter'
CodeClimate::TestReporter.start

require 'simplecov'
SimpleCov.command_name 'RSpec'

# This file is copied to spec/ when you run 'rails generate rspec:install'
ENV["RAILS_ENV"] ||= 'test'
require File.expand_path("../../config/environment", __FILE__)
require 'rspec'
require 'rspec/json_expectations'
require 'rspec/rails'
require 'remarkable'
require 'remarkable_activerecord'
require 'email_spec'
require 'authlogic/test_case'
require 'webrat'
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
    bing_api_path = '/json.aspx?'
    # bing_api_url = "#{BingSearch::API_HOST}#{BingSearch::API_ENDPOINT}"

    bing_common_params = {
        AppId: 'A4C32FAE6F3DB386FC32ED1C4F3024742ED30906',
        fdtrace: 1,
        Adult: 'moderate'
    }.freeze

    bing_hl_params = {
        Options: 'EnableHighlighting'
    }.freeze

    common_image_search_params = bing_common_params.
        merge(bing_hl_params).
        merge(sources: 'Spell Image').freeze

    stubs = Faraday::Adapter::Test::Stubs.new
    generic_bing_image_result = Rails.root.join('spec/fixtures/json/bing/image_search/white_house.json').read

    image_search_params = common_image_search_params.merge(query: 'white house')
    stubs.get("#{bing_api_path}#{image_search_params.to_param}") { [200, {}, generic_bing_image_result] }

    image_search_params = common_image_search_params.
        merge('image.count' => 20,
              query: '(white house) language:en (scopeid:usagovall OR site:gov OR site:mil)')
    stubs.get("#{bing_api_path}#{image_search_params.to_param}") { [200, {}, generic_bing_image_result] }

    image_search_params = common_image_search_params.merge(query: '(white house) language:en (site:nonsense.gov)')
    stubs.get("#{bing_api_path}#{image_search_params.to_param}") { [200, {}, generic_bing_image_result] }

    bing_image_no_result = Rails.root.join('spec/fixtures/json/bing/image_search/no_results.json').read
    image_search_params = common_image_search_params.merge(query: '(unusual image) language:en  (site:nonsense.gov)')
    stubs.get("#{bing_api_path}#{image_search_params.to_param}") { [200, {}, bing_image_no_result] }

    generic_bing_result_no_highlight = Rails.root.join('spec/fixtures/json/bing/web_search/ira_no_highlight.json').read
    common_no_hl_web_search_params = bing_common_params.merge(sources: 'Spell Web').freeze
    no_hl_web_search_params = common_no_hl_web_search_params.
      merge(query: 'no highlighting',
            'web.offset' => 11)

    stubs.get("#{bing_api_path}#{no_hl_web_search_params.to_param}") { [200, {}, generic_bing_result_no_highlight] }

    generic_bing_result = Rails.root.join('spec/fixtures/json/bing/web_search/ira.json').read
    common_web_search_params = bing_common_params.
      merge(bing_hl_params).
      merge(sources: 'Spell Web').freeze

    web_search_params = common_web_search_params.merge(query: 'highlight enabled')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, generic_bing_result] }

    web_search_params = common_web_search_params.merge(query: 'casa blanca')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, generic_bing_result] }

    web_search_params = common_web_search_params.merge(query: '中国')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, generic_bing_result] }

    web_search_params = common_web_search_params.merge(query: 'tradiksyon')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, generic_bing_result] }

    web_search_params = common_web_search_params.merge(query: 'english')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, generic_bing_result] }

    web_search_params = common_web_search_params.merge(query: '(english) language:en (site:nonsense.gov)')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, generic_bing_result] }

    page2_6results = Rails.root.join('spec/fixtures/json/bing/web_search/page2_6results.json').read
    web_search_params = common_web_search_params.
        merge(query: '(fewer) language:en (site:nonsense.gov)',
              'web.offset' => 10)
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, page2_6results] }

    total_no_results = Rails.root.join('spec/fixtures/json/bing/web_search/total_no_results.json').read
    web_search_params = common_web_search_params.merge(query: 'total_no_results')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, total_no_results] }

    two_results_1_missing_title = Rails.root.join('spec/fixtures/json/bing/web_search/2_results_1_missing_title.json').read
    web_search_params = common_web_search_params.merge(query: '2missing1')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, two_results_1_missing_title] }

    missing_urls = Rails.root.join('spec/fixtures/json/bing/web_search/missing_urls.json').read
    web_search_params = common_web_search_params.merge(query: 'missing_urls')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, missing_urls] }

    missing_descriptions = Rails.root.join('spec/fixtures/json/bing/web_search/missing_descriptions.json').read
    web_search_params = common_web_search_params.merge(query: 'missing_descriptions')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, missing_descriptions] }

    bing_no_results = Rails.root.join('spec/fixtures/json/bing/web_search/no_results.json').read

    web_search_params = common_web_search_params.merge(query: 'no_results')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, bing_no_results] }
    web_search_params = common_web_search_params.merge(query: '(no_results) language:en (site:nonsense.gov)')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, bing_no_results] }
    web_search_params = common_web_search_params.merge(query: '(Scientost) language:en (site:www100.whitehouse.gov)')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, bing_no_results] }

    bing_spelling = Rails.root.join('spec/fixtures/json/bing/web_search/spelling_suggestion.json').read
    web_search_params = common_web_search_params.merge(query: 'electro coagulation')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, bing_spelling] }

    web_search_params = common_web_search_params.merge(query: '(electro coagulation) language:en (scopeid:usagovall OR site:gov OR site:mil)')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, bing_spelling] }

    bing_spelling = Rails.root.join('spec/fixtures/json/bing/web_search/spelling_suggestion.json').read
    web_search_params = common_web_search_params.merge(query: '(electro coagulation) language:en (site:www.whitehouse.gov)')
    stubs.get("#{bing_api_path}#{web_search_params.to_param}") { [200, {}, bing_spelling] }

    oasis_api_path = "#{OasisSearch::API_ENDPOINT}?"
    oasis_image_result = Rails.root.join('spec/fixtures/json/oasis/image_search/shuttle.json').read
    image_search_params = { from: 0, query: 'shuttle', size: 10 }
    stubs.get("#{oasis_api_path}#{image_search_params.to_param}") { [200, {}, oasis_image_result] }

    i14y_api_path = "#{I14yCollections::API_ENDPOINT}/search?"
    i14y_web_result = Rails.root.join('spec/fixtures/json/i14y/web_search/marketplace.json').read
    i14y_search_params = { handles: 'one,two', language: 'en', offset: 0, query: 'marketplase', size: 20 }
    stubs.get("#{i14y_api_path}#{i14y_search_params.to_param}", ) { [200, {}, i14y_web_result] }

    google_api_path = '/customsearch/v1?'

    common_web_search_params = {
      alt: 'json',
      cx: GoogleSearch::SEARCH_CX,
      key: GoogleSearch::API_KEY,
      lr: 'lang_en',
      quotaUser: 'USASearch',
      safe: 'medium'
    }.freeze

    common_gss_api_search_params = common_web_search_params.
      merge(cx: 'my_cx',
            key: 'my_api_key')

    common_image_search_params = common_web_search_params.merge(searchType: 'image').freeze

    generic_google_image_result = Rails.root.join('spec/fixtures/json/google/image_search/obama.json').read
    image_search_params = common_image_search_params.merge(q: 'obama')
    stubs.get("#{google_api_path}#{image_search_params.to_param}") { [200, {}, generic_google_image_result] }

    generic_google_result = Rails.root.join('spec/fixtures/json/google/web_search/ira.json').read
    web_search_params = common_web_search_params.merge(q: 'highlight enabled')
    stubs.get("#{google_api_path}#{web_search_params.to_param}") { [200, {}, generic_google_result] }

    web_search_params = common_web_search_params.merge(q: 'no highlighting')
    stubs.get("#{google_api_path}#{web_search_params.to_param}") { [200, {}, generic_google_result] }

    gss_api_search_params = common_gss_api_search_params.merge(q: 'ira site:usa.gov')
    stubs.get("#{google_api_path}#{gss_api_search_params.to_param}") { [200, {}, generic_google_result] }

    gss_api_search_params = common_gss_api_search_params.
      merge(num: 5,
            q: 'ira site:usa.gov',
            start: 888)
    stubs.get("#{google_api_path}#{gss_api_search_params.to_param}") { [200, {}, generic_google_result] }

    es_web_search_params = common_web_search_params.merge(lr: 'lang_es', q: 'casa blanca')
    stubs.get("#{google_api_path}#{es_web_search_params.to_param}") { [200, {}, generic_google_result] }

    cn_web_search_params = common_web_search_params.merge(lr: 'lang_zh-cn', q: '中国')
    stubs.get("#{google_api_path}#{cn_web_search_params.to_param}") { [200, {}, generic_google_result] }

    ht_web_search_params = common_web_search_params.merge(q: 'tradiksyon').except(:lr)
    stubs.get("#{google_api_path}#{ht_web_search_params.to_param}") { [200, {}, generic_google_result] }

    gss_api_search_params = common_gss_api_search_params.merge(lr: 'lang_es', q: 'casa blanca site:usa.gov')
    stubs.get("#{google_api_path}#{gss_api_search_params.to_param}") { [200, {}, generic_google_result] }

    web_search_params = common_web_search_params.merge(q: 'english')
    stubs.get("#{google_api_path}#{web_search_params.to_param}") { [200, {}, generic_google_result] }

    google_no_results = Rails.root.join('spec/fixtures/json/google/web_search/no_results.json').read
    web_search_params = common_web_search_params.merge(q: 'no_results')
    stubs.get("#{google_api_path}#{web_search_params.to_param}") { [200, {}, google_no_results] }

    gss_api_search_params = common_gss_api_search_params.merge(q: 'mango smoothie site:usa.gov')
    stubs.get("#{google_api_path}#{gss_api_search_params.to_param}") { [200, {}, google_no_results] }

    google_no_next = Rails.root.join('spec/fixtures/json/google/web_search/no_next.json').read
    gss_api_search_params = common_gss_api_search_params.merge(q: 'healthy snack site:usa.gov')
    stubs.get("#{google_api_path}#{gss_api_search_params.to_param}") { [200, {}, google_no_next] }

    google_spelling = Rails.root.join('spec/fixtures/json/google/web_search/spelling_suggestion.json').read
    web_search_params = common_web_search_params.merge(q: 'electro coagulation')
    stubs.get("#{google_api_path}#{web_search_params.to_param}") { [200, {}, google_spelling] }

    web_search_params = common_web_search_params.merge(q: 'electro coagulation site:nps.gov')
    stubs.get("#{google_api_path}#{web_search_params.to_param}") { [200, {}, google_spelling] }

    gss_api_search_params = common_gss_api_search_params.merge(q: 'electro coagulation site:usa.gov')
    stubs.get("#{google_api_path}#{gss_api_search_params.to_param}") { [200, {}, google_spelling] }

    gss_api_search_params = common_gss_api_search_params.merge(q: 'electro coagulation site:www.whitehouse.gov', cx: '005675969675701682971:usi2bmqvnp8', key: '***REMOVED***')
    stubs.get("#{google_api_path}#{gss_api_search_params.to_param}") { [200, {}, google_spelling] }

    google_customcx = Rails.root.join('spec/fixtures/json/google/web_search/custom_cx.json').read
    web_search_params = common_web_search_params.merge(q: 'customcx', cx: '1234567890.abc', key: 'some_key')
    stubs.get("#{google_api_path}#{web_search_params.to_param}") { [200, {}, google_customcx] }

    common_azure_params = {
      :'$format' => 'JSON',
      :'$skip' => 0,
      :'$top' => 20,
      Market: "'en-US'",
      Query: "'healthy snack (site:usa.gov)'",
      Options: "'EnableHighlighting'"
    }

    azure_web_url = "#{AzureWebEngine::API_HOST}#{AzureWebEngine::API_ENDPOINT}"
    azure_web = RequestStub.new(azure_web_url, 'spec/fixtures/json/azure/web_only/', stubs)

    azure_web.stub_get_request(common_azure_params) { [200, {}, azure_web.raw_response('highlighting.json')] }

    azure_params = common_azure_params.except(:Options)
    azure_web.stub_get_request(azure_params) { [200, {}, azure_web.raw_response('no_highlighting.json')] }

    azure_params = common_azure_params.
      merge(Query: "'healthy snack (site:usa.gov) (-site:www.usa.gov AND -site:kids.usa.gov)'")
    azure_web.stub_get_request(azure_params) { [200, {}, azure_web.raw_response('no_next.json')] }

    azure_params = common_azure_params.
      merge(Market: "'es-US'",
            Query: "'educación (site:usa.gov)'")
    azure_web.stub_get_request(azure_params) { [200, {}, azure_web.raw_response('es_results.json')] }

    azure_params = common_azure_params.merge(Query: "'mango smoothie (site:usa.gov)'")
    azure_web.stub_get_request(azure_params) { [200, {}, azure_web.raw_response('no_results.json')] }

    azure_params = common_azure_params.merge(:'$skip' => 888)
    azure_web.stub_get_request(azure_params) { [200, {}, azure_web.raw_response('no_results.json')] }

    azure_params = common_azure_params.merge(:'$skip' => 10, :'$top' => 10, Query: "'fewer (site:nonsense.gov)'").reject { |k| k == :Options }
    azure_web.stub_get_request(azure_params) { [200, {}, azure_web.raw_response('page2_results.json')] }

    azure_params = common_azure_params.merge(Query: "'no_results (site:nonsense.gov)'", :'$top' => 10).reject { |k| k == :Options }
    azure_web.stub_get_request(azure_params) { [200, {}, azure_web.raw_response('no_results.json')] }

    azure_params = common_azure_params.merge(Query: "'english (site:nonsense.gov)'", :'$top' => 10).reject { |k| k == :Options }
    azure_web.stub_get_request(azure_params) { [200, {}, azure_web.raw_response('no_next.json')] }

    azure_image_url = "#{HostedAzureImageEngine::API_HOST}#{HostedAzureImageEngine::API_ENDPOINT}"
    azure_image = RequestStub.new(azure_image_url, 'spec/fixtures/json/azure/image_spell/', stubs)

    common_azure_image_params = {
      :'$format' => 'JSON',
      :'$skip' => 0,
      :'$top' => 5,
      ImageFilters: "'Aspect:Square'",
      Market: "'en-US'",
      Query: "'agncy (site:nasa.gov)'",
      Sources: "'image+spell'"
    }

    azure_image.stub_get_request(common_azure_image_params) { [200, {}, azure_image.raw_response('results.json')] }

    azure_image_params = common_azure_image_params.merge(Query: "'white house (site:nonsense.gov)'", :'$top' => 20)
    azure_image.stub_get_request(azure_image_params) { [200, {}, azure_image.raw_response('white_house.json')] }

    azure_image_params = common_azure_image_params.merge(:'$skip' => 998, Query: "'agncy (site:nasa.gov)'")
    azure_image.stub_get_request(azure_image_params) { [200, {}, azure_image.raw_response('no_next.json')] }

    azure_image_params = common_azure_image_params.merge(Query: "'agency (site:noresults.nasa.gov)'")
    azure_image.stub_get_request(azure_image_params) { [200, {}, azure_image.raw_response('no_results.json')] }

    azure_image_params = common_azure_image_params.merge(Query: "'white house (site:gov OR site:mil)'", :'$top' => 20)
    azure_image.stub_get_request(azure_image_params) { [200, {}, azure_image.raw_response('white_house.json')] }

    azure_composite_url = AzureCompositeEngine::API_ENDPOINT
    azure_composite = RequestStub.new(azure_composite_url, 'spec/fixtures/json/azure_composite/', stubs)

    common_azure_composite_params = {
      :'$format' => 'JSON',
      :'$skip' => 0,
      :'$top' => 5,
      ImageFilters: "''",
      Market: "'en-US'",
      Sources: "'web+spell'",
      Query: "'survy (site:www.census.gov)'",
    }

    azure_composite_params = common_azure_composite_params.merge({ Query: "'unpossible (site:www.census.gov)'" })
    azure_composite.stub_get_request(azure_composite_params) { [200, {}, azure_composite.raw_response('no_results.json')] }

    azure_composite_params = common_azure_composite_params
    azure_composite.stub_get_request(azure_composite_params) { [200, {}, azure_composite.raw_response('web_results.json')] }

    azure_composite_params = common_azure_composite_params.merge({ :'$skip' => 1000 })
    azure_composite.stub_get_request(azure_composite_params) { [200, {}, azure_composite.raw_response('no_next_page.json')] }

    azure_composite_params = common_azure_composite_params.merge({
      Query: "'survy (site:www.census.gov)'",
      ImageFilters: "'Aspect:Square'",
      Sources: "'image+spell'",
    })
    azure_composite.stub_get_request(azure_composite_params) { [200, {}, azure_composite.raw_response('image_results.json')] }

    bing_web_url = "#{BingSearch::API_HOST}#{BingSearch::API_ENDPOINT}"
    bing_web = RequestStub.new(bing_web_url, 'spec/fixtures/json/bing/web_search/', stubs)

    bing_web_params = bing_common_params
                        .merge(sources: 'Spell Web')

    bing_params = bing_web_params
                    .merge(bing_hl_params)
                    .merge(query: '(healthy snack) language:en (site:usa.gov)')
    bing_web.stub_get_request(bing_params) { [200, {}, bing_web.raw_response('highlighting.json')] }

    bing_params = bing_params.merge(query: '(educación) language:es (site:usa.gov)')
    bing_web.stub_get_request(bing_params) { [200, {}, bing_web.raw_response('es_highlighting.json')] }

    bing_params = bing_web_params.merge(query: '(healthy snack) language:en (site:usa.gov)')
    bing_web.stub_get_request(bing_params) { [200, {}, bing_web.raw_response('no_highlighting.json')] }

    bing_params = bing_web_params.merge(query: 'highlight enabled')
    bing_web.stub_get_request(bing_params) { [200, {}, bing_web.raw_response('ira.json')] }

    nutshell_success_params = {
      id: 'f6f91f185',
      jsonrpc: '2.0',
      method: 'editLead',
      params: {
        lead: {
          createdTime: '2015-02-01T05:00:00+00:00',
          customFields: { :'Site handle' => 'usasearch', :Status => 'inactive' },
          description: 'DigitalGov Search (usasearch)'
        }
      }
    }

    success_result = Rails.root.join('spec/fixtures/json/nutshell/edit_lead_response.json').read

    nutshell_error_params = {
      id: 'f6f91f185',
      jsonrpc: '2.0',
      method: 'editLead',
      params: {
        lead: {
          createdTime: '2015-02-01T05:00:00+00:00',
          customFields: { :'Bad field' => 'usasearch' },
          description: 'DigitalGov Search (usasearch)'
        }
      }
    }

    error_result = Rails.root.join('spec/fixtures/json/nutshell/edit_lead_response_with_error.json').read
    stubs.post(NutshellClient::ENDPOINT) do |env|
      case env[:body]
      when nutshell_success_params
        [200, {}, success_result]
      when nutshell_error_params
        [400, {}, error_result]
      end
    end

    test = Faraday.new do |builder|
      builder.adapter :test, stubs
      builder.response :rashify
      builder.response :json
    end

    # FIXME: this is in here just to get rcov coverage on connection classes
    params = { affiliate: 'wh', index: 'web', query: 'obama' }
    RateLimitedSearchApiConnection.new('rate_limited_api', 'http://search.usa.gov').get('/api/search.json', params)
    NutshellClient::NutshellApiConnection.new

    Faraday.stub!(:new).and_return test
    I14yCollections.establish_connection!
  end

  config.after(:suite) do
    TestServices::delete_es_indexes
    TestServices::stop_redis unless ENV['TRAVIS']
  end
end

Webrat.configure do |config|
  config.mode = :rails
end
