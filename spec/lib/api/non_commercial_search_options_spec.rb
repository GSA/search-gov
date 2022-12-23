require 'spec_helper'

describe Api::NonCommercialSearchOptions do
  describe '#attributes' do
    it 'includes sort_by option' do
      options = described_class.new sort_by: 'date'
      expect(options.attributes).to include(sort_by: 'date')
    end

    it 'includes site_limits option' do
      options = described_class.new site_limits: 'nps.gov search.gov'
      expect(options.attributes).to include(site_limits: 'nps.gov search.gov')
    end

    it 'includes tags option' do
      options = described_class.new tags: 'tag1, tag2'
      expect(options.attributes).to include(tags: 'tag1, tag2')
    end
  end
end
