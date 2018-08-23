require 'spec_helper'

describe BingV5WebEngine do
  subject { described_class.new(options) }

  it_behaves_like 'a Bing search'

  describe '#execute_query' do
    subject do
      described_class.new({
        offset: 20,
        limit: 10,
        query: 'consumer financial protection bureau',
        enable_highlighting: false,
      })
    end

    it 'should send a search request to Bing V5 and process the response' do
      result = subject.execute_query
      expect(result.start_record).to eq(21)
      expect(result.end_record).to eq(30)
      expect(result.next_offset).to be >= 30
      expect(result.total).to be > 1000
      expect(result.spelling_suggestion).to be_nil
      expect(result.tracking_information).to match(/[0-9A-F]{32}/)

      first_result = result.results.first
      expect(first_result.title).to_not be_empty
      expect(first_result.url).to match(URI.regexp)
      expect(first_result.description).to_not be_empty
    end
  end
end
