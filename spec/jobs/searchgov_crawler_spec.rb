require 'spec_helper'

describe SearchgovCrawler do
  let(:domain) { 'www.agency.gov' }
  let(:html) do
    <<~HTML
      <!DOCTYPE html>
      <html>
      <body>
      <a href="link1">link one</a>
      <a href="link2">link two</a>
      </body>
      </html>
    HTML
  end
  before do
    stub_request(:get, "https://#{domain}/").to_return(status: 200, body: html, headers: { content_type: 'text/html' })
    stub_request(:get, "https://#{domain}/link1").to_return(status: 200, body: "link 1", headers: { content_type: 'text/html' })
    stub_request(:get, "https://#{domain}/link2").to_return(status: 200, body: "link 2", headers: { content_type: 'text/html' })
  end

  describe '.perform' do
    subject(:perform) { SearchgovCrawler.perform(domain) }

    it 'creates searchgov urls' do
      perform
      expect(SearchgovUrl.pluck(:url)).to match_array(
        %w{ https://www.agency.gov/ https://www.agency.gov/link1 https://www.agency.gov/link2 }
      )
    end
  end
end
