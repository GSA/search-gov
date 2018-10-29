require 'spec_helper'

describe JobResultsPostProcessor do
  let(:results) do
    response = JSON.parse read_fixture_file('/json/usajobs_response.json')
    response['SearchResult']['SearchResultItems'].map do |result|
      Hashie::Mash::Rash.new(result)
    end
  end
  let(:post_processor) { JobResultsPostProcessor.new(results: results) }
  let(:post_processed_results) { post_processor.post_processed_results }
  let(:result) { post_processed_results.first }

  it 'renames the result fields' do
    expect(result.url).to eq 'https://www.usajobs.gov:443/GetJob/ViewDetails/390086900'
    expect(result.id).to eq 'FAR-F09-P001'
    expect(result.locations.first).to eq 'Fargo, North Dakota'
  end

  it 'converts the salary ranges to floats' do
    expect(result.minimum).to eq 19.54
    expect(result.maximum).to eq 26.23
  end
end
