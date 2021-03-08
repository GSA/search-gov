require 'spec_helper'
require 'data_generator/search_pool'

module DataGenerator
  describe IndexAdapter do
    subject { IndexAdapter.new(site_handle, search) }
    let(:site_handle) { 'site_beyond_site' }
    let(:search) { Search.new(timestamp, is_human, modules, query, clicks) }
    let(:timestamp) { Time.new(2015, 7, 14, 12, 15, 15, 0) }
    let(:modules) { ['NEWS'] }
    let(:query) { 'the ants in france' }
    let(:clicks) { [Click.new('url1', 1), Click.new('url2', 2)] }

    let(:es_client) { double(Elasticsearch::Transport::Client) }

    before do
      allow(ES).to receive(:client_writers).and_return([es_client])
    end

    describe '#index_search_and_clicks' do
      context 'for a human search' do
        let(:is_human) { true }

        it 'adds search and clicks to both the human-logstash- and logstash- indices' do
          expect(es_client).to receive(:index).with({
            index: 'human-logstash-2015.07.14',
            type: 'search',
            body: {
              '@version' => 1,
              '@timestamp' => '2015-07-14T12:15:15+00:00',
              type: 'search',
              modules: ['NEWS'],
              params: {
                affiliate: 'site_beyond_site',
                query: 'the ants in france'
              }
            }
          })
          expect(es_client).to receive(:index).with({
            index: 'logstash-2015.07.14',
            type: 'search',
            body: {
              '@version' => 1,
              '@timestamp' => '2015-07-14T12:15:15+00:00',
              type: 'search',
              modules: ['NEWS'],
              params: {
                affiliate: 'site_beyond_site',
                query: 'the ants in france'
              }
            }
          })

          expect(es_client).to receive(:index).with({
            index: 'human-logstash-2015.07.14',
            type: 'click',
            body: {
              '@version' => 1,
              '@timestamp' => '2015-07-14T12:15:15+00:00',
              type: 'click',
              modules: ['NEWS'],
              params: {
                affiliate: 'site_beyond_site',
                query: 'the ants in france',
                url: 'url1',
                position: 1
              }
            }
          })
          expect(es_client).to receive(:index).with({
            index: 'logstash-2015.07.14',
            type: 'click',
            body: {
              '@version' => 1,
              '@timestamp' => '2015-07-14T12:15:15+00:00',
              type: 'click',
              modules: ['NEWS'],
              params: {
                affiliate: 'site_beyond_site',
                query: 'the ants in france',
                url: 'url1',
                position: 1
              }
            }
          })

          expect(es_client).to receive(:index).with({
            index: 'human-logstash-2015.07.14',
            type: 'click',
            body: {
              '@version' => 1,
              '@timestamp' => '2015-07-14T12:15:15+00:00',
              type: 'click',
              modules: ['NEWS'],
              params: {
                affiliate: 'site_beyond_site',
                query: 'the ants in france',
                url: 'url2',
                position: 2
              }
            }
          })
          expect(es_client).to receive(:index).with({
            index: 'logstash-2015.07.14',
            type: 'click',
            body: {
              '@version' => 1,
              '@timestamp' => '2015-07-14T12:15:15+00:00',
              type: 'click',
              modules: ['NEWS'],
              params: {
                affiliate: 'site_beyond_site',
                query: 'the ants in france',
                url: 'url2',
                position: 2
              }
            }
          })

          subject.index_search_and_clicks
        end
      end

      context 'for a non-human search' do
        let(:is_human) { false }

        it 'adds search and clicks to just the logstash- index' do
          expect(es_client).to receive(:index).with({
            index: 'logstash-2015.07.14',
            type: 'search',
            body: {
              '@version' => 1,
              '@timestamp' => '2015-07-14T12:15:15+00:00',
              type: 'search',
              modules: ['NEWS'],
              params: {
                affiliate: 'site_beyond_site',
                query: 'the ants in france'
              }
            }
          })

          expect(es_client).to receive(:index).with({
            index: 'logstash-2015.07.14',
            type: 'click',
            body: {
              '@version' => 1,
              '@timestamp' => '2015-07-14T12:15:15+00:00',
              type: 'click',
              modules: ['NEWS'],
              params: {
                affiliate: 'site_beyond_site',
                query: 'the ants in france',
                url: 'url1',
                position: 1
              }
            }
          })

          expect(es_client).to receive(:index).with({
            index: 'logstash-2015.07.14',
            type: 'click',
            body: {
              '@version' => 1,
              '@timestamp' => '2015-07-14T12:15:15+00:00',
              type: 'click',
              modules: ['NEWS'],
              params: {
                affiliate: 'site_beyond_site',
                query: 'the ants in france',
                url: 'url2',
                position: 2
              }
            }
          })

          subject.index_search_and_clicks
        end
      end
    end
  end
end
