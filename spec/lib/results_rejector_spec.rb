require 'spec_helper'
describe ResultsRejector do

  class TestProcessor
    include ResultsRejector
  end

  let(:processor) { TestProcessor.new }

  describe '#url_is_excluded' do
    subject(:url_is_excluded) { processor.send(:url_is_excluded?, url) }
    let(:excluded_urls) { ['www.excluded.com'] }

    before do
      allow(processor).to receive(:excluded_urls).and_return(excluded_urls)
    end

    context 'when the url is excluded' do
      let(:url) { 'http://www.excluded.com' }

      it { is_expected.to be true }
    end

    context 'when the url is encoded' do
      let(:url) { 'http://www.example.gov/with%20spaces%20url.doc' }
      let(:excluded_urls) { ['www.example.gov/with spaces url.doc'] }

      it { is_expected.to be true }
    end

    context 'when the url is badly encoded' do #https://www.pivotaltracker.com/n/projects/24228/stories/137463695
      let(:url) do
        'https://www.dhs.gov/blog/2013/11/15/securing-our-nation%E2%EF%BF%BD%EF%BF%BDs-critical'
      end

      it { is_expected.to be false }
    end
  end
end
