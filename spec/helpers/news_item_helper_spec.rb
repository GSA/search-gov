require 'spec_helper'

describe NewsItemsHelper do
  let(:timestamp) { Time.current }

  describe "#news_item_time_ago_in_words(published_at)" do
    it 'should output time ago in words' do
      helper.news_item_time_ago_in_words(timestamp).should == 'less than a minute ago'
    end

    context 'when published at date is unavailable' do
      it 'does not output anything' do
        helper.news_item_time_ago_in_words(nil).should be_blank
      end
    end

    context 'when published at date is in the future' do
      let(:future_time) { 1.hour.from_now }
      it 'should not output anything' do
        helper.news_item_time_ago_in_words(future_time).should be_blank
      end
    end

    context 'when date stamps are not enabled' do
      it 'does not output anything' do
        expect(helper.news_item_time_ago_in_words(timestamp, '', false)).to be_blank
      end
    end
  end
end
