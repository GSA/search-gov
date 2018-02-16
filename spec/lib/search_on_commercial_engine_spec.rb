require 'spec_helper'

class DummySearch
  include SearchOnCommercialEngine
  attr_accessor :search_engine
  attr_accessor :affiliate

  def diagnostics
    @diagnostics ||= {}
  end

  def diagnostics_label
    'TEST'
  end
end

describe SearchOnCommercialEngine do
  fixtures :affiliates

  subject(:search) { DummySearch.new }
  let(:search_engine) { double(:search_engine, execute_query: search_result, query: nil) }
  let(:search_result) { double(:search_result, diagnostics: result_diagnostics) }
  let(:result_diagnostics) { :result_diagnostics }
  before do
    search.search_engine = search_engine
    search.affiliate = affiliates(:usagov_affiliate)
  end

  context 'when the search engine returns results' do
    it 'should add the results diagnostics to its own diagnostics hash' do
      search.search
      expect(search.diagnostics['TEST']).to eq(result_diagnostics)
    end
  end

  context 'when the search engine raises an error' do
    before do
      allow(search_engine).to receive(:execute_query).and_raise(SearchEngine::SearchError.new('something terrible'))
    end

    it 'should add the error info to its diagnostics hash' do
      search.search
      expect(search.diagnostics['TEST']).to eq({ error: 'COMMERCIAL_API_ERROR: something terrible' })
    end
  end
end
