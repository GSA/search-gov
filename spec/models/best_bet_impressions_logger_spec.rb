require 'spec_helper'

describe BestBetImpressionsLogger do
  fixtures :boosted_contents, :featured_collections, :affiliates

  let(:affiliate) { affiliates(:basic_affiliate) }

  context 'when featured collections are present' do
    let(:bbgs) { mock('featured collections', total: 1, results: [featured_collections(:basic)]) }

    it 'should log to Keen' do
      query_hash = { :affiliate_id => affiliate.id, :module => 'BBG', :query => 'foo', :model_id => featured_collections(:basic).id }
      Keen.should_receive(:publish_async).with(:impressions, query_hash)
      BestBetImpressionsLogger.log(affiliate.id, 'Foo', bbgs, nil)
    end
  end

  context 'when boosted contents are present' do
    let(:boos) { mock('boosted contents', results: [boosted_contents(:basic), boosted_contents(:another)]) }

    it 'should log to Keen' do
      query_hash1 = { :affiliate_id => affiliate.id, :module => 'BOOS', :query => 'foo', :model_id => boosted_contents(:basic).id }
      Keen.should_receive(:publish_async).with(:impressions, query_hash1)
      query_hash2 = { :affiliate_id => affiliate.id, :module => 'BOOS', :query => 'foo', :model_id => boosted_contents(:another).id }
      Keen.should_receive(:publish_async).with(:impressions, query_hash2)
      BestBetImpressionsLogger.log(affiliate.id, 'foo', nil, boos)
    end
  end

  context 'when there is a problem with EventMachine that raises a Keen::Error' do
    let(:boos) { mock('boosted contents', results: [boosted_contents(:basic), boosted_contents(:another)]) }

    before do
      Keen.stub(:publish_async).and_raise Keen::Error.new('foo')
    end

    it 'should catch the exception and log the error' do
      Rails.logger.should_receive(:error).twice
      BestBetImpressionsLogger.log(affiliate.id, 'foo', nil, boos)
    end
  end

  context 'when there is a problem with EventMachine that raises a RuntimeError' do
    let(:boos) { mock('boosted contents', results: [boosted_contents(:basic), boosted_contents(:another)]) }

    before do
      Keen.stub(:publish_async).and_raise RuntimeError.new('foo')
    end

    it 'should catch the exception and log the error' do
      Rails.logger.should_receive(:error).twice
      BestBetImpressionsLogger.log(affiliate.id, 'foo', nil, boos)
    end
  end
end