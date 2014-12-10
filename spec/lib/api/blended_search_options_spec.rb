require 'spec_helper'

describe Api::BlendedSearchOptions do
  describe '#attributes' do
    it 'includes highlighting' do
      options = described_class.new enable_highlighting: true
      expect(options.attributes).to include(highlighting: true)
    end
  end
end
