# frozen_string_literal: true

describe BulkZombieUrls::Results do
  let(:results) { described_class.new('Test File') }

  it 'initializes with correct attributes' do
    expect(results.file_name).to eq('Test File')
    expect(results.ok_count).to eq(0)
    expect(results.updated).to eq(0)
    expect(results.error_count).to eq(0)
  end

  it 'tracks successful deletions' do
    results.delete_ok
    expect(results.ok_count).to eq(1)
  end

  it 'tracks errors' do
    results.add_error('Error message', '123')
    expect(results.error_count).to eq(1)
    expect(results.errors['123']).to include('Error message')
  end

  it 'retrieves URLs with specific errors' do
    results.add_error('Missing URL', '123')
    expect(results.urls_with('123')).to include('Missing URL')
  end
end
