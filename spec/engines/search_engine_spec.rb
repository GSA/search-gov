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
  let(:cache_name) { 'some_cache' }
  let(:api_connection) { instance_double(CachedSearchApiConnection, get: cached_response, namespace: cache_name) }
  let(:cached_response) { CachedSearchApiConnectionResponse.new(:response, cache_name) }
  let(:parsed_response) { double(SearchEngineResponse, results: [:foo, :bar, :baz], 'diagnostics=': nil, 'tracking_information': 'trackery') }

  before do
    subject.api_connection = api_connection
    subject.parsed_response = parsed_response
    allow(Time).to receive(:now).and_return(0, 41, 43, 47)
  end

  describe '#execute_query' do
    context 'when no errors occur' do
      before do
        allow(api_connection).to receive(:get) { cached_response }
      end

      it 'returns the parsed response' do
        expect(subject.execute_query).to eq(parsed_response)
      end

      it 'adds api diagnostics to the response' do
        expect(parsed_response).to receive(:'diagnostics=').with({
          result_count: 3,
          from_cache: true,
          retry_count: 0,
          elapsed_time_ms: 2000,
          tracking_information: 'trackery'
        })
        subject.execute_query
      end
    end

    context 'when a non-timeout error occurs' do
      before do
        allow(api_connection).to receive(:get).and_raise('nope')
      end

      it 'raises a SearchError' do
        expect { subject.execute_query }.to raise_error(SearchEngine::SearchError, 'nope')
      end
    end

    context 'when a timeout error occurs once' do
      let(:cache_name) { 'none' }

      before do
        @error_count = 0
        allow(api_connection).to receive(:get) do
          @error_count += 1
          raise Faraday::TimeoutError.new('nope') if @error_count < 2
          cached_response
        end
      end

      it 'still returns the parsed response' do
        expect(subject.execute_query).to eq(parsed_response)
      end

      it 'adds api diagnostics to the response' do
        expect(parsed_response).to receive(:'diagnostics=').with({
          result_count: 3,
          from_cache: true,
          retry_count: 1,
          elapsed_time_ms: 4000,
          tracking_information: 'trackery'
        })
        subject.execute_query
      end
    end

    context 'when a timeout error occurs repeatedly' do
      let(:cache_name) { 'none' }

      before do
        allow(api_connection).to receive(:get).and_raise(Faraday::TimeoutError.new('nope'))
      end

      it 'raises a SearchError' do
        expect { subject.execute_query }.to raise_error(SearchEngine::SearchError, 'nope')
      end
    end
  end
end
