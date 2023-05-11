require 'spec_helper'

describe I14yPostProcessor do
  describe '#normalized_results' do
    subject(:normalized_results) { described_class.new(true, results, excluded_urls).normalized_results(5) }

    let(:excluded_urls) { [] }

    context 'when results have all attributes' do
      let(:results) do
        results = []
        5.times { |index| results << Hashie::Mash::Rash.new(title: "title #{index}", content: "content #{index}", path: "http://foo.gov/#{index}", changed: '2020-09-09 00:00:00 UTC', created: '2020-09-09 00:00:00 UTC', thumbnail_url: 'https://search.gov/img.svg') }
        results
      end

      it_behaves_like 'a search with normalized results' do
        let(:normalized_results) { described_class.new(true, results, excluded_urls).normalized_results(5) }
      end

      it 'has a published date, updated date, and thumbnaul URL' do
        normalized_results[:results].each do |result|
          expect(result[:updatedDate]).to eq('September 9th, 2020')
          expect(result[:publishedDate]).to eq('September 9th, 2020')
          expect(result[:thumbnailUrl]).to eq('https://search.gov/img.svg')
        end
      end

      it 'does not use unbounded pagination' do
        expect(normalized_results[:unboundedResults]).to be false
      end
    end

    context 'when results are missing some attributes' do
      let(:results) do
        results = []
        5.times { |index| results << Hashie::Mash::Rash.new(title: "title #{index}", content: "content #{index}", path: "http://foo.gov/#{index}") }
        results
      end

      it_behaves_like 'a search with normalized results' do
        let(:normalized_results) { described_class.new(true, results, excluded_urls).normalized_results(5) }
      end

      it 'has no published date, updated date, or thumbnaul URL' do
        normalized_results[:results].each do |result|
          expect(result[:updatedDate]).to be_nil
          expect(result[:publishedDate]).to be_nil
          expect(result[:thumbnailUrl]).to be_nil
        end
      end

      it 'does not use unbounded pagination' do
        expect(normalized_results[:unboundedResults]).to be false
      end
    end
  end

  describe '#post_process_results' do
    let(:result) do
      { content: 'doc content',
        description: 'doc description',
        path: 'http://www.foo.com',
        created: Time.now }
    end
    let(:excluded_urls) { [] }

    before do
      described_class.new(true, results, excluded_urls).post_process_results
    end

    context 'when a result has no description' do
      let(:results) do
        [Hashie::Mash.new(result.merge(description: nil, content: "content with \uE000match\uE001"))]
      end

      it 'sets the body as the description' do
        expect(results.first.description).to eq "content with \uE000match\uE001"
      end
    end

    context 'when the description does not contain a match' do
      let(:results) do
        [Hashie::Mash.new(result.merge(description: 'no match', content: "content with \uE000match\uE001"))]
      end

      it 'sets the body as the description' do
        expect(results.first.description).to eq "content with \uE000match\uE001"
      end
    end

    context 'when there is a match in the description' do
      let(:results) do
        [Hashie::Mash.new(result.merge(description: "description with \uE000match\uE001",
                                       content: content))]
      end

      context 'when there is no match in the body' do
        let(:content) { 'content without match' }

        it 'includes the description then the body' do
          expect(results.first.description).to eq "description with \uE000match\uE001"
        end
      end

      context 'when there is a match in the body' do
        let(:content) { "content with \uE000match\uE001" }

        it 'includes the description then the body' do
          expect(results.first.description).to eq "description with \uE000match\uE001...content with \uE000match\uE001"
        end
      end
    end

    context 'when the affiliate has excluded a url' do
      let(:results) { [Hashie::Mash.new(result)] }
      let(:excluded_urls) { ['www.foo.com'] }

      it 'does not include results for that url' do
        expect(results).to be_empty
      end
    end
  end
end
