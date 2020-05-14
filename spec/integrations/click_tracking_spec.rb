require 'spec_helper'

describe 'Click tracking', type: :feature, js: true do
  let!(:affiliate) { affiliates(:basic_affiliate) }

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
      expect(page).to have_selector('div[data-a="nps.gov"]', id: 'search')
      expect(page).to have_selector('div[data-l="en"]', id: 'search')
      expect(page).to have_selector('div[data-q="boosted"]', id: 'search')
      expect(page).to have_selector('div[data-t]', id: 'search')

      expect(page).to have_selector('a[data-click]')
    end

    describe 'the user clicks a search result' do
      it 'js sends in an ajax click event' do
        expect(Click).to receive(:log)

        click_link 'A boosted search result'
        sleep(1) # wait for ajax
      end
    end
  end
end
