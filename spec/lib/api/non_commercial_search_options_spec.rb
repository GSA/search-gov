require 'spec_helper'

describe Api::NonCommercialSearchOptions do
  describe '#attributes' do
    it 'includes sort_by option' do
      options = described_class.new sort_by: 'date'
      expect(options.attributes).to include(sort_by: 'date')
    end

    it 'includes tags option' do
      options = described_class.new tags: 'tag1, tag2'
      expect(options.attributes).to include(tags: 'tag1, tag2')
    end
  end

  it 'includes audience option' do
    options = described_class.new audience: 'everyone'
    expect(options.attributes).to include(audience: 'everyone')
  end

  it 'includes content_type option' do
    options = described_class.new content_type: 'article'
    expect(options.attributes).to include(content_type: 'article')
  end

  it 'includes mime_type option' do
    options = described_class.new mime_type: 'application/pdf'
    expect(options.attributes).to include(mime_type: 'application/pdf')
  end

  it 'includes searchgov_custom1 option' do
    options = described_class.new searchgov_custom1: 'custom1'
    expect(options.attributes).to include(searchgov_custom1: 'custom1')
  end

  it 'includes searchgov_custom2 option' do
    options = described_class.new searchgov_custom2: 'custom2'
    expect(options.attributes).to include(searchgov_custom2: 'custom2')
  end

  it 'includes searchgov_custom3 option' do
    options = described_class.new searchgov_custom3: 'custom3'
    expect(options.attributes).to include(searchgov_custom3: 'custom3')
  end
end
