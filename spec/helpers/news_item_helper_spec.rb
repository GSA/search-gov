require 'spec_helper'

describe NewsItemsHelper do
  describe "#news_item_time_ago_in_words(published_at)" do
    it 'should output time ago in words' do
      current = Time.current
      helper.news_item_time_ago_in_words(current).should == 'less than a minute ago'
    end

    context 'when published at date is in the future' do
      it 'should not output anything' do
        current = 1.hour.from_now
        helper.news_item_time_ago_in_words(current).should be_blank
      end
    end
  end
end