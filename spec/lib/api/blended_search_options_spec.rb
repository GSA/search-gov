require 'spec_helper'

describe Api::BlendedSearchOptions do
  describe '#attributes' do
    it 'includes sort_by option' do
      options = described_class.new sort_by: 'date'
      expect(options.attributes).to include(sort_by: 'date')
    end
  end
end
