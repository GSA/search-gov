require 'spec_helper'

describe I14yPostProcessor do
  describe '#normalized_results' do
    let(:normalized_result_keys) { [:description, :url, :title] }
    let(:results) do
      results = []
      5.times { |x| results << Hashie::Mash::Rash.new(title: 'title', content: 'content', path: "http://foo.gov/#{x}") }
      results
    end
    let(:excluded_urls) { [] }

    it_behaves_like 'a search with normalized results' do
      let(:normalized_results) { described_class.new(true, results, excluded_urls).normalized_results }
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
        [Hashie::Mash.new(result.merge(description: nil, content: "content with \uE000match\uE001" ))]
      end

      it 'sets the body as the description' do
        expect(results.first.description).to eq "content with \uE000match\uE001"
      end
    end

    context 'when the description does not contain a match' do
      let(:results) do
        [Hashie::Mash.new(result.merge(description: 'no match', content: "content with \uE000match\uE001" ))]
      end

      it 'sets the body as the description' do
        expect(results.first.description).to eq "content with \uE000match\uE001"
      end
    end

    context 'when there is a match in the description' do
      let(:results) do
        [Hashie::Mash.new(result.merge(description: "description with \uE000match\uE001",
                                       content: content ))]
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
