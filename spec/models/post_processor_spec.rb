require 'spec_helper'

describe PostProcessor do
  describe '#total_pages' do
    subject(:post_processor) { described_class.new }

    it 'returns zero when there are no results' do
      expect(post_processor.total_pages(0)).to eq(0)
    end
  end
end
