require 'spec_helper'

describe TrendingUrl do
  fixtures :affiliates

  describe '.all' do
    context 'when affiliate does not actually exist' do
      before do
        redis = Redis.new(url: REDIS_SYSTEM_URL)
        redis.sadd('TrendingUrls:some_unknown_aff', %w{http://www.gov.gov/url3 http://www.gov.gov/url1})
      end

      it 'should ignore the entry' do
        expect(described_class.all).not_to be_present
      end
    end
  end
end