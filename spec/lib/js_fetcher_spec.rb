# frozen_string_literal: true

describe JsFetcher do
  # Below live site will pinged on each test run, should be handled with VCR cassette config.
  let(:url) { 'https://search.gov/javascript-test.html' }

  it 'fetches page with javascript response' do
    js_response = described_class.fetch(url)
    expect(js_response).not_to be_nil
    expect(js_response).to include('Javascript-inserted content. Used for integration testing.')
  end
end
