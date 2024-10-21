RSpec.describe BulkAffiliateStyles::Results do
  subject(:results) { described_class.new(filename) }

  let(:filename) { 'test.csv' }

  describe '#initialize' do
    it 'initializes with correct default values' do
      expect(results.file_name).to eq(filename)
      expect(results.ok_count).to eq(0)
      expect(results.updated).to eq(0)
      expect(results.error_count).to eq(0)
      expect(results.affiliates).to be_empty
    end
  end

  describe '#add_ok' do
    it 'increments ok_count and adds affiliate_id to affiliates' do
      results.add_ok(1)
      results.add_ok(2)

      expect(results.ok_count).to eq(2)
      expect(results.affiliates).to include(1, 2)
    end
  end

  describe '#add_error' do
    it 'increments error_count and stores error_message by affiliate_id' do
      results.add_error('Invalid data', 3)
      results.add_error('Connection error', 4)

      expect(results.error_count).to eq(2)
      expect(results.affiliates_with(3)).to eq('Invalid data')
      expect(results.affiliates_with(4)).to eq('Connection error')
    end
  end

  describe '#total_count' do
    it 'returns the sum of ok_count and error_count' do
      results.add_ok(1)
      results.add_error('Invalid data', 2)

      expect(results.total_count).to eq(2)
    end
  end

  describe '#affiliates_with' do
    it 'returns the error message for a given affiliate_id' do
      results.add_error('Invalid data', 3)

      expect(results.affiliates_with(3)).to eq('Invalid data')
    end
  end
end
