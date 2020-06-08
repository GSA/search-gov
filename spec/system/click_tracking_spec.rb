# frozen_string_literal: true

require 'spec_helper'

describe 'Click tracking', js: true do
  let!(:affiliate) { affiliates(:basic_affiliate) }
  let(:click_mock) { instance_double(Click, valid?: true, log: nil) }

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
      it 'js sends in an ajax click event' do
        allow(Click).to receive(:new).and_return click_mock

        click_link 'A boosted search result'
        sleep(1) # wait for ajax

        expect(click_mock).to have_received(:log)
      end
    end
  end
end
