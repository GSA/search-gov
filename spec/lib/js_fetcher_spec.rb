# frozen_string_literal: true

require 'spec_helper'

describe JsFetcher do
  describe '.fetch' do
    let(:url) { 'https://digital.gov/guides/search/' }
    let(:options) { instance_double('Selenium::WebDriver::Firefox::Options') }
    let(:driver)  { instance_double('Selenium::WebDriver::Driver') }
    let(:manage)  { instance_double('Selenium::WebDriver::Driver::Manage') }
    let(:timeouts) { instance_double('Selenium::WebDriver::Timeouts') }

    before do
      # Stub Firefox options creation and configuration
      allow(Selenium::WebDriver::Options).to receive(:firefox).and_return(options)
      allow(options).to receive(:add_argument).with('-headless')
      allow(options).to receive(:add_preference).with('browser.sessionstore.resume_from_crash', false)
      allow(options).to receive(:add_preference).with('browser.tabs.warnOnClose', false)
      allow(options).to receive(:add_preference).with('general.useragent.override', anything)

      # Stub driver construction
      allow(Selenium::WebDriver).to receive(:for).with(:firefox, options: options).and_return(driver)

      # Stub timeouts chain
      allow(driver).to receive(:manage).and_return(manage)
      allow(manage).to receive(:timeouts).and_return(timeouts)
      allow(timeouts).to receive(:implicit_wait=).with(5)
      allow(timeouts).to receive(:page_load=).with(30)

      # Avoid real sleeps in specs
      allow(JsFetcher).to receive(:sleep)

      # Normal driver interactions
      allow(driver).to receive(:get).with(url)
      allow(driver).to receive(:page_source).and_return('<html>fake content</html>')
      allow(driver).to receive(:quit)
    end

    it 'opens a headless Firefox driver, navigates to the URL, returns page source, and quits the driver' do
      result = described_class.fetch(url)

      # Verify driver constructed with Firefox and our options
      expect(Selenium::WebDriver).to have_received(:for).with(:firefox, options: options)

      # Verify it navigated to the correct URL
      expect(driver).to have_received(:get).with(url)

      # Verify it returned page_source
      expect(result).to eq('<html>fake content</html>')

      # Verify it quit the driver
      expect(driver).to have_received(:quit)
    end
  end
end
