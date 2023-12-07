require 'spec_helper'

describe NewsItemsHelper do
  let(:timestamp) { Time.current }

  describe '#news_item_time_ago_in_words(published_at)' do
    it 'outputs time ago in words' do
      expect(helper.news_item_time_ago_in_words(timestamp)).to eq('less than 5 seconds ago')
    end

    context 'when published at date is unavailable' do
      it 'does not output anything' do
        expect(helper.news_item_time_ago_in_words(nil)).to be_blank
      end
    end

    context 'when published at date is in the future' do
      let(:future_time) { 1.hour.from_now }

      it 'does not output anything' do
        expect(helper.news_item_time_ago_in_words(future_time)).to be_blank
      end
    end

    context 'when date stamps are not enabled' do
      it 'does not output anything' do
        expect(helper.news_item_time_ago_in_words(timestamp, '', false)).to be_blank
      end
    end
  end
end
