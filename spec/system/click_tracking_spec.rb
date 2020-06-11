# frozen_string_literal: true

require 'spec_helper'

describe 'Click tracking', js: true do
  let!(:affiliate) { affiliates(:basic_affiliate) }

  before do
    affiliate.boosted_contents.create!(title: 'A boosted search result',
                                       description: 'An example description',
                                       url: 'http://example.com',
                                       status: 'active',
                                       publish_start_on: Date.current)
    ElasticBoostedContent.commit
  end

  describe 'a user searches for a best bet' do
    before do
      visit '/search?affiliate=nps.gov&query=boosted'
    end

    it 'the search results have the expected data attributes' do
      expect(page).to have_selector('div[data-affiliate="nps.gov"]', id: 'search')
      expect(page).to have_selector('div[data-vertical="web"]', id: 'search')
      expect(page).to have_selector('div[data-query="boosted"]', id: 'search')

      long_string = 'a[data-click=\'{"position":1,"module_code":"BOOS"}\']'
      expect(page).to have_selector(long_string)
    end

    describe 'the user clicks a search result' do
      it 'js sends in a click event, creating the expected log line.' do
        allow(Rails.logger).to receive(:info).and_call_original

        click_link 'A boosted search result'

        expect(Rails.logger).to have_received(:info).with(start_with('[Click]')) do |logline|
          expect(logline).to include('"url":"http://example.com/"')
          expect(logline).to include('"query":"boosted"')
          expect(logline).to include('"client_ip":"127.0.0.1"')
          expect(logline).to include('"affiliate":"nps.gov"')
          expect(logline).to include('"position":"1"')
          expect(logline).to include('"module_code":"BOOS"')
          expect(logline).to include('"vertical":"web"')
          expect(logline).to include('"user_agent":')
        end
      end
    end
  end
end
