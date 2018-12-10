require 'spec_helper'

describe BingV5ImageEngine do
  subject { described_class.new(options) }

  it_behaves_like 'a Bing search'

  describe '#execute_query' do
    subject do
      described_class.new({
        offset: 20,
        limit: 10,
        query: 'whitehouse dog',
      })
    end

    it 'should send a search request to Bing V5 and process the response' do
      result = subject.execute_query
      expect(result.start_record).to eq(21)
      expect(result.end_record).to eq(30)
      expect(result.next_offset).to be >= 30
      expect(result.total).to be > 100
      expect(result.spelling_suggestion).to be_nil
      expect(result.tracking_information).to match(/[0-9A-F]{32}/)

      first_result = result.results.first
      expect(first_result.title).to match(%r{dog}i)
      expect(first_result.source_url).to match(URI.regexp)
      expect(first_result.media_url).to match(URI.regexp)
      expect(first_result.display_url).not_to be_empty
      expect(first_result.content_type).to match(%r{image})
      expect(first_result.file_size).to be > 0
      expect(first_result.width).to be > 0
      expect(first_result.height).to be > 0

      thumbnail = first_result.thumbnail
      expect(thumbnail.media_url).to match(URI.regexp)
      expect(thumbnail.width).to be > 0
      expect(thumbnail.height).to be > 0
    end
  end
end
