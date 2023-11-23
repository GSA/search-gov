# frozen_string_literal: true

shared_examples 'a search with normalized results' do
  let(:result_count) { 5 }
  let(:total_pages) { 1 }

  it 'has a normalized set of keys' do
    expect(normalized_results.keys).to contain_exactly(%i[results total totalPages unboundedResults])
  end

  it 'returns correct total' do
    expect(normalized_results[:total]).to eq(results_count)
  end

  it 'returns the correct number of pages' do
    expect(normalized_results[:totalPages]).to eq(total_pages)
  end

  context 'with five results' do
    it 'returns the correct number of results' do
      expect(normalized_results[:results].length).to eq(result_count)
    end

    it 'has a normalized set of keys for results' do
      normalized_results[:results].each do |result|
        expect(result.keys).to include(%i[description url title])
      end
    end

    it 'returns normalized results for the title, description, and URL' do
      normalized_results[:results].each_with_index do |result, index|
        expect(result[:title]).to eq("title #{index}")
        expect(result[:description]).to eq("content #{index}")
        expect(result[:url]).to eq("http://foo.gov/#{index}")
      end
    end
  end
end
