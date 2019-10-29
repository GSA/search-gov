require 'spec_helper'

describe '/api/v2/search' do
  fixtures :affiliates

  let(:affiliate) { affiliates(:usagov_affiliate) }

  context 'when there are matching results' do
    before do
      current_time = DateTime.parse 'Wed, 17 Dec 2014 18:33:43 +0000'
      current_date = current_time.to_date

      ElasticBoostedContent.recreate_index
      affiliate.boosted_contents.delete_all

      attributes = {
        title: "api v2 title manual-1",
        description: "api v2 description manual-1",
        url: "https://search.gov/manual-1",
        status: 'active',
        publish_start_on: current_date
      }
      affiliate.boosted_contents.create! attributes

      ElasticBoostedContent.commit

      ElasticFeaturedCollection.recreate_index
      affiliate.featured_collections.destroy_all

      graphic_best_bet_attributes = {
        title: 'api v2 how-to',
        status: 'active',
        publish_start_on: current_date
      }
      graphic_best_bet = affiliate.featured_collections.build graphic_best_bet_attributes

      link_attributes = {
        title: 'api v2 title how-to-1',
        url: 'https://search.gov/how-to-1',
        position: 0
      }
      graphic_best_bet.featured_collection_links.build link_attributes

      graphic_best_bet.save!

      ElasticFeaturedCollection.commit

      ElasticIndexedDocument.recreate_index
      affiliate.indexed_documents.destroy_all

      (1..2).each do |i|
        attributes = {
          title: "api v2 title docs-#{i}",
          url: "https://search.gov/docs-#{i}",
          description: "api v2 description docs-#{i} #{'extremely long content ' * 8}",
          last_crawl_status: IndexedDocument::OK_STATUS
        }
        affiliate.indexed_documents.create! attributes
      end

      ElasticIndexedDocument.commit

      ElasticNewsItem.recreate_index
      affiliate.rss_feeds.destroy_all

      rss_feed = affiliate.rss_feeds.build(name: 'RSS')
      url = 'https://search.gov/all.atom'
      rss_feed_url = RssFeedUrl.rss_feed_owned_by_affiliate.build(url: url)
      rss_feed_url.save!(validate: false)
      rss_feed.rss_feed_urls = [rss_feed_url]
      rss_feed.save!

      (3..4).each do |i|
        attributes = {
          title: "api v2 title news-#{i}",
          link: "https://search.gov/news-#{i}",
          guid: "blog-#{i}",
          description: "v2 description news-#{i}  #{'extremely long content ' * 8}",
          published_at: current_time.advance(days: -i)
        }
        rss_feed_url.news_items.create! attributes
      end

      ElasticNewsItem.commit

      ElasticSaytSuggestion.recreate_index
      affiliate.sayt_suggestions.delete_all


      affiliate.sayt_suggestions.create!(phrase: 'api endpoint')
      affiliate.sayt_suggestions.create!(phrase: 'api instruction')

      ElasticSaytSuggestion.commit
    end

    context 'when enable_highlighting param is not present' do
      let(:expected_hash_response) do
        fixture_path = 'spec/fixtures/json/blended/with_highlighting.json'
        JSON.parse(Rails.root.join(fixture_path).read, symbolize_names: true)
      end

      it 'returns JSON results with highlighting' do
        get '/api/v2/search', params: { access_key: 'usagov_key',
                                        affiliate: 'usagov',
                                        query: 'api' }
        expect(response.status).to eq(200)

        hash_response = JSON.parse response.body, symbolize_names: true
        expect(hash_response[:web][:total]).to eq(4)
        expect(hash_response[:web][:next_offset]).to be_nil
        expect(hash_response[:web][:results]).to match_array(expected_hash_response[:web][:results])
        hash_response[:text_best_bets].each_with_index do |result, index|
          expect(result[:id]).to_not be_nil
          expect(result[:title]).to eq(expected_hash_response[:text_best_bets][index][:title])
          expect(result[:url]).to eq(expected_hash_response[:text_best_bets][index][:url])
          expect(result[:description]).to eq(expected_hash_response[:text_best_bets][index][:description])
        end
        hash_response[:graphic_best_bets].each_with_index do |result, index|
          expect(result[:id]).to_not be_nil
          expect(result[:title]).to eq(expected_hash_response[:graphic_best_bets][index][:title])
          expect(result[:title_url]).to eq(expected_hash_response[:graphic_best_bets][index][:title_url])
          expect(result[:links]).to match_array(expected_hash_response[:graphic_best_bets][index][:links])
        end
        expect(hash_response[:related_search_terms]).to match_array(expected_hash_response[:related_search_terms])
      end
    end

    context 'when enable_highlighting = false' do
      let(:expected_hash_response) do
        fixture_path = 'spec/fixtures/json/blended/without_highlighting.json'
        JSON.parse(Rails.root.join(fixture_path).read, symbolize_names: true)
      end

      it 'returns JSON results without highlighting' do
        get '/api/v2/search', params: { access_key: 'usagov_key',
                                        affiliate: 'usagov',
                                        query: 'api',
                                        enable_highlighting: 'false' }
        expect(response.status).to eq(200)

        hash_response = JSON.parse response.body, symbolize_names: true
        expect(hash_response[:web][:total]).to eq(4)
        expect(hash_response[:web][:results]).to match_array(expected_hash_response[:web][:results])
        hash_response[:text_best_bets].each_with_index do |result, index|
          expect(result[:id]).to_not be_nil
          expect(result[:title]).to eq(expected_hash_response[:text_best_bets][index][:title])
          expect(result[:url]).to eq(expected_hash_response[:text_best_bets][index][:url])
          expect(result[:description]).to eq(expected_hash_response[:text_best_bets][index][:description])
        end
        hash_response[:graphic_best_bets].each_with_index do |result, index|
          expect(result[:id]).to_not be_nil
          expect(result[:title]).to eq(expected_hash_response[:graphic_best_bets][index][:title])
          expect(result[:title_url]).to eq(expected_hash_response[:graphic_best_bets][index][:title_url])
          expect(result[:links]).to match_array(expected_hash_response[:graphic_best_bets][index][:links])
        end
        expect(hash_response[:related_search_terms]).to match_array(expected_hash_response[:related_search_terms])
      end
    end

    context 'when limit = 1' do
      let(:expected_hash_response) do
        fixture_path = 'spec/fixtures/json/blended/with_limit.json'
        JSON.parse(Rails.root.join(fixture_path).read, symbolize_names: true)
      end

      it 'returns JSON results without highlighting' do
        get '/api/v2/search', params: { access_key: 'usagov_key',
                                        affiliate: 'usagov',
                                        query: 'api',
                                        limit: '1' }
        expect(response.status).to eq(200)

        hash_response = JSON.parse response.body, symbolize_names: true
        expect(hash_response[:web][:total]).to eq(4)
        expect(hash_response[:web][:next_offset]).to eq(1)
        expect(hash_response[:web][:results].count).to eq(1)
        hash_response[:text_best_bets].each_with_index do |result, index|
          expect(result[:id]).to_not be_nil
          expect(result[:title]).to eq(expected_hash_response[:text_best_bets][index][:title])
          expect(result[:url]).to eq(expected_hash_response[:text_best_bets][index][:url])
          expect(result[:description]).to eq(expected_hash_response[:text_best_bets][index][:description])
        end
        hash_response[:graphic_best_bets].each_with_index do |result, index|
          expect(result[:id]).to_not be_nil
          expect(result[:title]).to eq(expected_hash_response[:graphic_best_bets][index][:title])
          expect(result[:title_url]).to eq(expected_hash_response[:graphic_best_bets][index][:title_url])
          expect(result[:links]).to match_array(expected_hash_response[:graphic_best_bets][index][:links])
        end
        expect(hash_response[:related_search_terms]).to match_array(expected_hash_response[:related_search_terms])
      end
    end

    context 'when offset = 3' do
      it 'returns JSON results without highlighting' do
        get '/api/v2/search', params: { access_key: 'usagov_key',
                                        affiliate: 'usagov',
                                        query: 'api',
                                        offset: '2' }
        expect(response.status).to eq(200)

        hash_response = JSON.parse response.body, symbolize_names: true
        expect(hash_response[:web][:total]).to eq(4)
        expect(hash_response[:web][:results].count).to eq(2)
        expect(hash_response[:text_best_bets]).to be_empty
        expect(hash_response[:graphic_best_bets]).to be_empty
        expect(hash_response[:related_search_terms]).to be_empty
      end
    end

    context 'when sort_by=date' do
      let(:expected_hash_response) do
        fixture_path = 'spec/fixtures/json/blended/sorted_by_date.json'
        JSON.parse(Rails.root.join(fixture_path).read, symbolize_names: true)
      end

      it 'returns JSON results sorted by published_at in descending order' do
        get '/api/v2/search', params: { access_key: 'usagov_key',
                                        affiliate: 'usagov',
                                        query: 'api',
                                        sort_by: 'date' }
        expect(response.status).to eq(200)

        hash_response = JSON.parse response.body, symbolize_names: true
        expect(hash_response[:web][:total]).to eq(4)
        expect(hash_response[:web][:results].first(2)).to match_array(expected_hash_response[:web][:results].first(2))
        hash_response[:text_best_bets].each_with_index do |result, index|
          expect(result[:id]).to_not be_nil
          expect(result[:title]).to eq(expected_hash_response[:text_best_bets][index][:title])
          expect(result[:url]).to eq(expected_hash_response[:text_best_bets][index][:url])
          expect(result[:description]).to eq(expected_hash_response[:text_best_bets][index][:description])
        end
        hash_response[:graphic_best_bets].each_with_index do |result, index|
          expect(result[:id]).to_not be_nil
          expect(result[:title]).to eq(expected_hash_response[:graphic_best_bets][index][:title])
          expect(result[:title_url]).to eq(expected_hash_response[:graphic_best_bets][index][:title_url])
          expect(result[:links]).to match_array(expected_hash_response[:graphic_best_bets][index][:links])
        end
        expect(hash_response[:related_search_terms]).to match_array(expected_hash_response[:related_search_terms])
      end
    end

    context 'when query contains spelling error' do
      it 'returns JSON results with spelling correction' do
        get '/api/v2/search', params: { access_key: 'usagov_key',
                                        affiliate: 'usagov',
                                        query: 'descripton',
                                        sort_by: 'date' }
        expect(response.status).to eq(200)

        hash_response = JSON.parse response.body, symbolize_names: true
        expect(hash_response[:web][:spelling_correction]).to eq('description')
      end

      context 'when the query exists in SuggestionBlock' do
        before { SuggestionBlock.create!(query: 'descripton') }

        it 'returns JSON results with nil spelling correction' do
          get '/api/v2/search', params: { access_key: 'usagov_key',
                                          affiliate: 'usagov',
                                          query: 'descripton',
                                          sort_by: 'date' }
          expect(response.status).to eq(200)

          hash_response = JSON.parse response.body, symbolize_names: true
          expect(hash_response[:web][:spelling_correction]).to be_nil
        end
      end
    end
  end

  context 'when one of the parameter is invalid' do
    context 'when access_key is not present' do
      it 'returns errors' do
        get '/api/v2/search', params: { affiliate: 'not-usagov', query: 'api' }
        expect(response.status).to eq(400)

        hash_response = JSON.parse response.body, symbolize_names: true
        expect(hash_response[:errors].first).to eq('access_key must be present')
      end
    end

    context 'when access_key is invalid' do
      it 'returns errors' do
        get '/api/v2/search', params: { access_key: 'not_usagov_key',
                                        affiliate: 'usagov',
                                        query: 'api' }
        expect(response.status).to eq(400)

        hash_response = JSON.parse response.body, symbolize_names: true
        expect(hash_response[:errors].first).to eq('access_key is invalid')
      end
    end

    context 'when affiliate is invalid' do
      it 'returns errors' do
        get '/api/v2/search', params: { access_key: 'usagov_key',
                                        affiliate: 'not-usagov',
                                        query: 'api' }
        expect(response.status).to eq(400)

        hash_response = JSON.parse response.body, symbolize_names: true
        expect(hash_response[:errors].first).to eq('affiliate not found')
      end
    end

    context 'when limit is invalid' do
      it 'returns errors' do
        get '/api/v2/search', params: { access_key: 'usagov_key',
                                        affiliate: 'usagov',
                                        limit: '5000',
                                        query: 'api' }
        expect(response.status).to eq(400)

        hash_response = JSON.parse response.body, symbolize_names: true
        expect(hash_response[:errors].first).to eq('limit must be between 1 and 50')
      end
    end

    context 'when offset is invalid' do
      it 'returns errors' do
        get '/api/v2/search', params: { access_key: 'usagov_key',
                                        affiliate: 'usagov',
                                        offset: '5000',
                                        query: 'api' }
        expect(response.status).to eq(400)

        hash_response = JSON.parse response.body, symbolize_names: true
        expect(hash_response[:errors]).to include('offset must be between 0 and 1000')
      end
    end

    context 'when query is blank' do
      it 'returns errors' do
        get '/api/v2/search', params: { access_key: 'usagov_key',
                                        affiliate: 'usagov',
                                        query: '' }
        expect(response.status).to eq(400)

        hash_response = JSON.parse response.body, symbolize_names: true
        expect(hash_response[:errors]).to include('a search term must be present')
      end
    end
  end

  context 'when the search includes advanced parameters' do
    let(:advanced_search_params) do
      { access_key: 'usagov_key',
        affiliate: 'usagov',
        query: 'taxes site:irs.gov',
        query_not: 'exclude',
        query_quote: 'exact phrase',
        query_or: 'alternative',
        filetype: 'pdf',
        filter: '2'
      }
    end
    let(:hash_response) { JSON.parse response.body, symbolize_names: true }

    it 'returns the formatted query' do
      get '/api/v2/search', params: advanced_search_params
      expect(hash_response[:query]).to eq 'taxes site:irs.gov "exact phrase" -exclude (alternative) filetype:pdf'
    end
  end
end
