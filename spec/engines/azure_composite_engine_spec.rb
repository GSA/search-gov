require 'spec_helper'

describe AzureCompositeEngine do
  describe '#execute_query' do
    let(:engine) do
      described_class.new api_key: '***REMOVED***',
                          language: 'en',
                          sources: sources,
                          image_filters: image_filters,
                          offset: offset,
                          limit: 5,
                          query: query
    end
    let(:sources) { 'web+spell' }
    let(:image_filters) { nil }
    let(:offset) { 0 }
    let(:query) { 'survy (site:www.census.gov)' }

    subject(:response) { engine.execute_query }

    context 'when no results are present' do
      let(:query) { 'unpossible (site:www.census.gov)' }

      it 'sets total and next_offset' do
        expect(response.total).to eq(0)
        expect(response.next_offset).to eq(nil)
      end
    end

    context 'when web results are present' do
      it 'sets total and next_offset' do
        expect(response.total).to eq(291000)
        expect(response.next_offset).to eq(5)
      end

      it 'sets spelling suggestion' do
        expect(response.spelling_suggestion).to eq('survey')
      end
    end

    context 'when no next page of results is available' do
      let(:offset) { 1000 }

      it 'sets total and next_offset' do
        expect(response.total).to eq(365)
        expect(response.next_offset).to eq(nil)
      end
    end

    context 'when image results are present' do
      let(:sources) { 'image+spell' }
      let(:image_filters) { 'Aspect:Square' }

      it 'sets total and next_offset' do
        expect(response.total).to eq(502)
        expect(response.next_offset).to eq(5)
      end

      it 'sets spelling suggestion' do
        expect(response.spelling_suggestion).to eq('survey')
      end
    end
  end
end
