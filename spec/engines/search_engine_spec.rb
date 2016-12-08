require 'spec_helper'

class DummySearchEngine < SearchEngine
  attr_accessor :parsed_response

  def params
    {}
  end

  def api_endpoint
    '/some/endpoint'
  end

  def parse_search_engine_response(_)
    @parsed_response
  end
end

describe SearchEngine do
  subject { DummySearchEngine.new(options) }
  let(:options) { {} }
  let(:api_connection) { double(:api_connection, get: cached_response) }
  let(:cached_response) { CachedSearchApiConnectionResponse.new(:response, cache_name) }
  let(:parsed_response) { double(SearchEngineResponse, results: [:foo, :bar, :baz], :'diagnostics=' => nil) }
  let(:statsd) { double(Datadog::Statsd, decrement: nil, gauge: nil, increment: nil) }
  let(:cache_name) { 'some_cache' }

  before do
    subject.api_connection = api_connection
    subject.parsed_response = parsed_response
    subject.stub(:statsd).and_return(statsd)
    statsd.stub(:batch).and_yield(statsd)
    Time.stub(:now).and_return(0, 41, 43, 47)
  end

  describe '#execute_query' do
    context 'when no errors occur' do
      before do
        api_connection.stub(:get) { cached_response }
      end

      it 'returns the parsed response' do
        expect(subject.execute_query).to eq(parsed_response)
      end

      it 'adds api diagnostics to the response' do
        parsed_response.should_receive(:'diagnostics=').with({
          result_count: 3,
          from_cache: 'some_cache',
          retry_count: 0,
          elapsed_time_ms: 2000,
        })
        subject.execute_query
      end

      it 'reports an incoming search to datadog' do
        statsd.should_receive(:increment).with('incoming_count')
        subject.execute_query
      end

      context 'and the result is served from a cache' do
        it 'resports a cache hit to datadog' do
          statsd.should_receive(:increment).with('cache_hit_count')
          subject.execute_query
        end

        it 'reports a net zero number of outgoing searches to datadog' do
          statsd.should_receive(:increment).with('outgoing_count')
          statsd.should_receive(:decrement).with('outgoing_count')
          subject.execute_query
        end
      end

      context 'and the result is not served from a cache' do
        let(:cache_name) { 'none' }

        it 'does not report a cache hit to datadog' do
          statsd.should_not_receive(:increment).with('cache_hit_count')
          subject.execute_query
        end

        it 'reports an outgoing search to datadog' do
          statsd.should_receive(:increment).with('outgoing_count')
          subject.execute_query
        end

        it 'reports the outgoing duration to datadog' do
          statsd.should_receive(:gauge).with('outgoing_duration_ms', 2000)
          subject.execute_query
        end

        it 'reports a zero retry count to datadog' do
          statsd.should_receive(:gauge).with('retry_count', 0)
          subject.execute_query
        end

        it 'reports the number of results to datadog' do
          statsd.should_receive(:gauge).with('result_count', 3)
          subject.execute_query
        end
      end
    end

    context 'when a non-timeout error occurs' do
      before do
        api_connection.stub(:get).and_raise('nope')
      end

      it 'raises a SearchError' do
        expect { subject.execute_query }.to raise_error(SearchEngine::SearchError, 'nope')
      end

      it 'reports an error to datadog' do
        statsd.should_receive(:increment).with('error_count')
        begin
          subject.execute_query
        rescue
        end
      end
    end

    context 'when a timeout error occurs once' do
      let(:cache_name) { 'none' }

      before do
        @error_count = 0
        api_connection.stub(:get) do
          @error_count += 1
          raise Faraday::TimeoutError.new('nope') if @error_count < 2
          cached_response
        end
      end

      it 'still returns the parsed response' do
        expect(subject.execute_query).to eq(parsed_response)
      end

      it 'adds api diagnostics to the response' do
        parsed_response.should_receive(:'diagnostics=').with({
          result_count: 3,
          from_cache: 'none',
          retry_count: 1,
          elapsed_time_ms: 4000,
        })
        subject.execute_query
      end

      it 'reports a 1 retry count to datadog' do
        statsd.should_receive(:gauge).with('retry_count', 1)
        subject.execute_query
      end
    end

    context 'when a timeout error occurs repeatedly' do
      let(:cache_name) { 'none' }

      before do
        api_connection.stub(:get).and_raise(Faraday::TimeoutError.new('nope'))
      end

      it 'raises a SearchError' do
        expect { subject.execute_query }.to raise_error(SearchEngine::SearchError, 'nope')
      end

      it 'reports an error to datadog' do
        statsd.should_receive(:increment).with('error_count')
        begin
          subject.execute_query
        rescue
        end
      end
    end
  end
end
