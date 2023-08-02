# frozen_string_literal: true

require 'spec_helper'

describe ResultsPostProcessor do
  describe '#translate_highlights' do
    subject(:highlighted_text) { described_class.new.translate_highlights(text_with_highlights) }

    let(:text_with_highlights) { "\uE000healthcare\uE001.gov" }

    it 'returns a string with strong HTML tags' do
      expect(highlighted_text).to eq '<strong>healthcare</strong>.gov'
    end

    context 'when the text is nil' do
      let(:text_with_highlights) { nil }

      it 'returns nil' do
        expect(highlighted_text).to be_nil
      end
    end
  end

  describe '#rss_module' do
    subject(:rss_results) { described_class.new.rss_module(news_results) }

    let(:news_results) { [Hashie::Mash::Rash.new(title: 'News item 0', link: 'http://search.gov/news0', published_at: '09-01-2022'), Hashie::Mash::Rash.new(title: 'News item 1', link: 'http://search.gov/news1', published_at: '09-01-2022')] }

    it 'returns rss results' do
      rss_results.each_with_index do |result, index|
        expect(result).to eq({ title: "News item #{index}", url: "http://search.gov/news#{index}", publishedAt: '09-01-2022' })
      end
    end

    context 'when there are no results' do
      let(:news_results) { [] }

      it 'returns nil' do
        expect(rss_results).to be_empty
      end
    end
  end

  describe '#truncate_description' do
    subject(:truncated_description) { described_class.new.truncate_description(html) }

    let(:html) { 'Mars. Imagine Living on <strong>Mars</strong> May 2, 2002 Artist concept of the Mars Exploration...be like if Mars were your home? What would life be like if Mars were your home. This is a very long test string. It should exceed 280 characters. The quick brown fox jumps over the lazy dog. We need to truncate this text.' }

    it 'returns a truncated HTML string' do
      expect(truncated_description).to eq 'Mars. Imagine Living on <strong>Mars</strong> May 2, 2002 Artist concept of the Mars Exploration...be like if Mars were your home? What would life be like if Mars were your home. This is a very long test string. It should exceed 280 characters. The quick brown fox jumps over the lazy dog. We need ...'
    end

    context 'when the description is nil' do
      let(:html) { nil }

      it 'returns an empty string' do
        expect(truncated_description).to eq ''
      end
    end
  end

  describe '#total_pages' do
    subject(:total_pages) { described_class.new.total_pages(total_results) }

    context 'when there are no results' do
      let(:total_results) { 0 }

      it { is_expected.to eq(0) }
    end

    context 'when there is one page of results' do
      let(:total_results) { 10 }

      it { is_expected.to eq(1) }
    end

    context 'when there is more than one page of results' do
      context 'when the last page has exactly 20 results' do
        let(:total_results) { 60 }

        it { is_expected.to eq(3) }
      end

      context 'when the last page has less than 20 results' do
        let(:total_results) { 65 }

        it { is_expected.to eq(4) }
      end
    end

    context 'when there are more than 500 pages of results' do
      let(:total_results) { 15_000 }

      it { is_expected.to eq(500) }
    end

    context 'when an invalid value is passed in' do
      let(:total_results) { {} }

      it { is_expected.to eq(0) }
    end
  end
end
