require 'spec_helper'

describe ExcludedUrl do
  fixtures :affiliates

  before do
    @valid_attributes = {
      url: 'https://www.usa.gov/excludeme.html',
      affiliate_id: affiliates(:basic_affiliate).id
    }
  end

  context 'when creating a new excluded url' do
    before do
      described_class.create!(@valid_attributes)
    end

    it { is_expected.to validate_presence_of :url }
    it { is_expected.to validate_uniqueness_of(:url).scoped_to(:affiliate_id).case_insensitive }
    it { is_expected.to belong_to(:affiliate) }

    it 'should decode the URL' do
      excluded_url = described_class.create!(@valid_attributes.merge(url: 'https://www.usa.gov/exclude%20me.html'))
      expect(excluded_url.url).to eq('https://www.usa.gov/exclude me.html')
    end
  end

  describe '#dup' do
    subject(:original_instance) { described_class.create!(@valid_attributes) }

    include_examples 'site dupable'
  end
end
