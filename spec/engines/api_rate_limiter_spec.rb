require 'spec_helper'

describe ApiRateLimiter do
  let(:namespace) { 'my_api' }
  let!(:today) { Date.new(2014, 1, 1) }
  let(:key) { 'my_api:2014-01-01:used_count'.freeze }

  subject(:rate_limiter) { ApiRateLimiter.new(namespace) }

  before do
    ApiRateLimiter.redis.flushdb
    Date.stub(:current).and_return(today)
  end

  describe '#on_within_limit' do
    let(:connection) { mock('connection') }

    context 'when limit has not been reached' do
      before do
        OutboundRateLimit.create!(name: namespace, limit: 100)
      end

      it 'yields to the block and increments used count' do
        rate_limiter.get_or_initialize_used_count(key).should eq(0)

        connection.should_receive(:get).once
        rate_limiter.within_limit do
          connection.get
        end

        rate_limiter.get_or_initialize_used_count(key).should eq(1)
      end
    end

    context 'when limit has been reached' do
      let(:allowed_calls) { 2 }
      before do
        OutboundRateLimit.create!(name: namespace, limit: 2)
        connection.should_receive(:get).exactly(allowed_calls).times

        2.times { rate_limiter.within_limit { connection.get } }
      end

      it 'does not yield to the block' do
        rate_limiter.within_limit { connection.get }
        rate_limiter.get_or_initialize_used_count(key).should eq(allowed_calls)
      end

      it 'logs warning message' do
        Rails.logger.should_receive(:warn).with(/limit reached/)
        rate_limiter.within_limit { connection.get }
      end

      context "when soft limiting is enabled" do
        subject(:rate_limiter) { ApiRateLimiter.new(namespace, true) }
        let(:allowed_calls) { 3 }

        it 'yields to the block and increments used count' do
          rate_limiter.within_limit { connection.get }
          rate_limiter.get_or_initialize_used_count(key).should eq(allowed_calls)
        end

        it 'logs warning message' do
          Rails.logger.should_receive(:warn).with(/limit reached/)
          rate_limiter.within_limit { connection.get }
        end
      end
    end
  end
end
