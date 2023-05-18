# frozen_string_literal: true

require 'spec_helper'

describe ResultsPostProcessor do
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
