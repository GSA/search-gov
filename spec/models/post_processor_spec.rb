# frozen_string_literal: true

require 'spec_helper'

describe PostProcessor do
  describe '#total_pages' do
    subject(:post_processor) { described_class.new }

    it 'returns zero when there are no results' do
      expect(post_processor.total_pages(0)).to eq(0)
    end

    it 'returns one when there are 20 or fewer results' do
      expect(post_processor.total_pages(1)).to eq(1)
      expect(post_processor.total_pages(10)).to eq(1)
      expect(post_processor.total_pages(20)).to eq(1)
      expect(post_processor.total_pages(21)).not_to eq(1)
    end

    context 'when an invalid value is passed in' do
      it 'returns zero' do
        expect(post_processor.total_pages({})).to eq(0)
      end
    end
  end
end
