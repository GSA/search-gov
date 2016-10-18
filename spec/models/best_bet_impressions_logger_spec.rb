require 'spec_helper'

describe BestBetImpressionsLogger do
  fixtures :boosted_contents, :featured_collections, :affiliates

  let(:affiliate) { affiliates(:basic_affiliate) }

  context 'when featured collections are present' do
    let(:bbgs) { double('featured collections', total: 2, results: [featured_collections(:basic),featured_collections(:another)]) }

    it 'should log to Keen' do
      query_hash1 = { :affiliate_id => affiliate.id, :module => 'BBG', :query => 'foo', :model_id => featured_collections(:basic).id }
      KeenLogger.should_receive(:log).with(:impressions, query_hash1)
      query_hash2 = { :affiliate_id => affiliate.id, :module => 'BBG', :query => 'foo', :model_id => featured_collections(:another).id }
      KeenLogger.should_receive(:log).with(:impressions, query_hash2)
      BestBetImpressionsLogger.log(affiliate.id, 'Foo', bbgs, nil)
    end
  end

  context 'when boosted contents are present' do
    let(:boos) { double('boosted contents', results: [boosted_contents(:basic), boosted_contents(:another)]) }

    it 'should log to Keen' do
      query_hash1 = { :affiliate_id => affiliate.id, :module => 'BOOS', :query => 'foo', :model_id => boosted_contents(:basic).id }
      Keen.should_receive(:publish_async).with(:impressions, query_hash1)
      query_hash2 = { :affiliate_id => affiliate.id, :module => 'BOOS', :query => 'foo', :model_id => boosted_contents(:another).id }
      Keen.should_receive(:publish_async).with(:impressions, query_hash2)
      BestBetImpressionsLogger.log(affiliate.id, 'foo', nil, boos)
    end
  end

end
