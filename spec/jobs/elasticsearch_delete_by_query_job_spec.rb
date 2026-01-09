# frozen_string_literal: true

require 'spec_helper'

RSpec.describe ElasticsearchDeleteByQueryJob, type: :job do
  let(:index_name) { "#{ENV.fetch('SEARCHELASTIC_INDEX')}_#{SecureRandom.uuid}" }
  let(:client) { ES.client }
  let(:retention_days) { ENV.fetch('OPENSEARCH_SEARCH_RETENTION_DAYS', 30).to_i }

  before do
    # Reset Index
    client.indices.delete(index: index_name) if client.indices.exists?(index: index_name)
    client.indices.create(index: index_name)

    # Seed Documents
    # 2 Old documents (older than retention_days), 1 New document (within retention_days)
    documents = [
      { id: 'old1', updated_at: (retention_days + 10).days.ago.iso8601 },
      { id: 'old2', updated_at: (retention_days + 1).days.ago.iso8601 },
      { id: 'new1', updated_at: 2.days.ago.iso8601 }
    ]

    documents.each do |doc|
      client.index(index: index_name, id: doc[:id], body: doc)
    end

    # Force refresh so documents are searchable
    client.indices.refresh(index: index_name)
  end

  it 'deletes documents older than the retention period' do
    # Ensure starting count is 3
    expect(client.count(index: index_name)['count']).to eq(3)

    # Run Job
    # Using retention days from env (assuming 30 based on OPENSEARCH_SEARCH_RETENTION_DAYS in our test config)
    described_class.perform_now

    # delete_by_query is async in our job, but CircleCI is too fast sometimes,
    # so we need to poll for a few seconds until the count drops to 1.
    Timeout.timeout(10) do
      loop do
        client.indices.refresh(index: index_name)
        break if client.count(index: index_name)['count'] == 1
        sleep 0.5
      end
    end

    expect(client.count(index: index_name)['count']).to eq(1)
    
    # Verify the correct doc remains
    expect(client.exists?(index: index_name, id: 'new1')).to be_truthy
    expect(client.exists?(index: index_name, id: 'old1')).to be_falsey
    expect(client.exists?(index: index_name, id: 'old2')).to be_falsey
  end
end
