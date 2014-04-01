require 'spec_helper'

describe BestBetsDrillDown do
  fixtures :affiliates, :search_modules
  let(:affiliate) { affiliates(:basic_affiliate) }

  describe '#module_name' do
    let(:best_bets_drill_down) { BestBetsDrillDown.new(affiliate, 'BOOS') }

    it 'should return the search module name' do
      best_bets_drill_down.module_name.should == 'Best Bets Text'
    end
  end

  describe "#search_module_stats" do
    context 'best bets text' do
      let(:first_boosted_content) { BoostedContent.create!(affiliate: affiliate,
                                                           url: "http://www.someaffiliate.gov/foobar",
                                                           title: "The foobar page",
                                                           description: "All about foobar, boosted to the top",
                                                           status: 'active',
                                                           publish_start_on: Date.yesterday) }
      let(:second_boosted_content) { BoostedContent.create!(affiliate: affiliate,
                                                            url: "http://www.someaffiliate.gov/blat",
                                                            title: "The next page",
                                                            description: "All about another thing, boosted to the top",
                                                            status: 'active',
                                                            publish_start_on: Date.yesterday) }
      context 'when there are impressions and clicks' do
        let(:best_bets_drill_down) { BestBetsDrillDown.new(affiliate, 'BOOS') }
        before do
          filters = [{ :property_name => 'affiliate_id', :operator => 'eq', :property_value => affiliate.id },
                     { :property_name => 'module', :operator => 'eq', :property_value => 'BOOS' }]
          query_hash = { :timeframe => 'this_month', :group_by => 'model_id', :filters => filters }
          keen_impressions_response = [{ "model_id" => first_boosted_content.id, "result" => 4 },
                                       { "model_id" => second_boosted_content.id, "result" => 10 },
                                       { "model_id" => -1, "result" => 10 }]
          keen_clicks_response = [{ "model_id" => second_boosted_content.id, "result" => 1 },
                                  { "model_id" => -1, "result" => 1 }]
          Keen.stub(:count).with(:impressions, query_hash).and_return keen_impressions_response
          Keen.stub(:count).with(:clicks, query_hash).and_return keen_clicks_response
        end

        it 'should return impressions/clicks/ctr by existing module instance for the current month, sorted by CTR' do
          best_bets_drill_down.search_module_stats.size.should == 2
          stats = best_bets_drill_down.search_module_stats
          stats[first_boosted_content.id].should == { model: first_boosted_content, impression_count: 4, click_count: 0, clickthru_ratio: 0.0 }
          stats[second_boosted_content.id].should == { model: second_boosted_content, impression_count: 10, click_count: 1, clickthru_ratio: 10.0 }
          stats.values.collect { |stat| stat[:clickthru_ratio] }.should == [10.0, 0.0]
        end
      end
    end

    context 'best bets: graphics' do
      let(:first_featured_collection) { FeaturedCollection.create!(:title => 'Did You Mean Roes or Rose?',
                                                                   :title_url => "http://www.gov.gov/1",
                                                                   :status => 'active',
                                                                   :publish_start_on => '07/01/2011',
                                                                   :affiliate => affiliate) }

      context 'when there are impressions and clicks' do
        let(:best_bets_drill_down) { BestBetsDrillDown.new(affiliate, 'BBG') }
        before do
          filters = [{ :property_name => 'affiliate_id', :operator => 'eq', :property_value => affiliate.id },
                     { :property_name => 'module', :operator => 'eq', :property_value => 'BBG' }]
          query_hash = { :timeframe => 'this_month', :group_by => 'model_id', :filters => filters }
          keen_impressions_response = [{ "model_id" => first_featured_collection.id, "result" => 4 }]
          keen_clicks_response = [{ "model_id" => first_featured_collection.id, "result" => 1 }]
          Keen.stub(:count).with(:impressions, query_hash).and_return keen_impressions_response
          Keen.stub(:count).with(:clicks, query_hash).and_return keen_clicks_response
        end

        it 'should return impressions/clicks/ctr by existing module instance for the current month, sorted by CTR' do
          best_bets_drill_down.search_module_stats.size.should == 1
          stats = best_bets_drill_down.search_module_stats
          stats[first_featured_collection.id].should == { model: first_featured_collection, impression_count: 4, click_count: 1, clickthru_ratio: 25.0 }
        end
      end
    end
  end
end
