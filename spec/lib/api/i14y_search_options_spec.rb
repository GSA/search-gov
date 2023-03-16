# frozen_string_literal: true

describe Api::I14ySearchOptions do
  describe '#attributes' do
    it 'includes sort_by option' do
      options = described_class.new sort_by: 'date'
      expect(options.attributes).to include(sort_by: 'date')
    end

    it 'includes tags option' do
      options = described_class.new tags: 'tag1, tag2'
      expect(options.attributes).to include(tags: 'tag1, tag2')
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

    it 'includes updated dates options in m/d/y format' do
      options = described_class.new updated_since: '2020-01-01', updated_until: '2021-01-01'
      expect(options.attributes).
        to include(since_date: '01/01/2020', until_date: '01/01/2021')
    end

    it 'includes created dates options in m/d/y format' do
      options = described_class.new created_since: '2020-01-01', created_until: '2021-01-01'
      expect(options.attributes).
        to include(created_since_date: '01/01/2020', created_until_date: '01/01/2021')
    end
  end

  describe 'validations' do
    let(:required_params) do
      {
        access_key: 'my_access_key',
        affiliate: 'my_site_handle',
        query: 'my query'
      }
    end

    it 'rejects invalid date parameters' do
      options = described_class.new(required_params.merge(updated_since: 'not a date'))
      expect(options).not_to be_valid
      expect(options.errors.full_messages).to include('since_date must be in YYYY-mm-dd format')
    end

    it 'accepts valid date parameters' do
      options = described_class.new(required_params.merge(created_until: '2020-01-01'))
      expect(options).to be_valid
    end
  end
end
