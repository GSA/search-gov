require 'spec_helper'

describe BingV5WebEngine do
  it_behaves_like 'a Bing V5 engine'

  describe '#params' do
    subject { described_class.new({ enable_highlighting: :enable_highlighting }) }

    it 'uses "WebPages,SpellSuggestions" for responseFilter' do
      expect(subject.params[:responseFilter]).to eq('WebPages,SpellSuggestions')
    end

    it 'gets textDecorations from options' do
      expect(subject.params[:textDecorations]).to eq(:enable_highlighting)
    end
  end

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
