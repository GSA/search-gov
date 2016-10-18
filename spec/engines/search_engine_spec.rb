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
  let(:cached_response) { CachedSearchApiConnectionResponse.new(:response, 'some_cache') }
  let(:parsed_response) { double(SearchEngineResponse, results: [:foo, :bar, :baz], :'diagnostics=' => nil) }

  before do
    subject.api_connection = api_connection
    subject.parsed_response = parsed_response
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
    end

    context 'when a non-timeout error occurs' do
      before do
        api_connection.stub(:get).and_raise('nope')
      end

      it 'raises a SearchError' do
        expect { subject.execute_query }.to raise_error(SearchEngine::SearchError, 'nope')
      end
    end

    context 'when a timeout error occurs once' do
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
          from_cache: 'some_cache',
          retry_count: 1,
          elapsed_time_ms: 4000,
        })
        subject.execute_query
      end
    end

    context 'when a timeout error occurs repeatedly' do
      before do
        api_connection.stub(:get).and_raise(Faraday::TimeoutError.new('nope'))
      end

      it 'raises a SearchError' do
        expect { subject.execute_query }.to raise_error(SearchEngine::SearchError, 'nope')
      end
    end
  end
end
