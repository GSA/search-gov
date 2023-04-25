# frozen_string_literal: true

shared_examples 'a search with normalized results' do
  let(:normalized_result_keys) { %i[description url title updatedDate publishedDate thumbnailUrl] }
  let(:result_count) { 5 }

  it 'returns the correct number of results' do
    expect(normalized_results.length).to eq(result_count)
  end

  it 'has a normalized set of keys' do
    normalized_results.each do |result|
      expect(result.keys).to contain_exactly(*normalized_result_keys)
    end
  end

  it 'returns normalized results for the title, description, and URL' do
    normalized_results.each_with_index do |result, index|
      expect(result[:title]).to eq("title #{index}")
      expect(result[:description]).to eq("content #{index}")
      expect(result[:url]).to eq("http://foo.gov/#{index}")
    end
  end
end
