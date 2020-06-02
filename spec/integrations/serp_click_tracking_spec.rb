require 'spec_helper'

describe 'Click tracking', type: :feature, js: true do
  let!(:affiliate) { affiliates(:basic_affiliate) }
  let(:click_mock) { instance_double(ClickSerp, valid?: true) }

  before do
    affiliate.boosted_contents.create!(title: 'A boosted search result',
                                       description: 'An example description',
                                       url: "http://example.com",
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

      expect(page).to have_selector('a[data-click=\'{"position":1,"module_code":"BOOS"}\']')
    end

    describe 'the user clicks a search result' do
      it 'js sends in an ajax click event' do
        expect(ClickSerp).to receive(:new).and_return click_mock
        expect(click_mock).to receive(:log)

        click_link 'A boosted search result'
        sleep(1) # wait for ajax
      end
    end
  end
end
