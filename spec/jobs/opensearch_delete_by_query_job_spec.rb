# frozen_string_literal: true

require 'spec_helper'

RSpec.describe OpenSearchDeleteByQueryJob, type: :job do
  let(:index_name) { "#{ENV.fetch('OPENSEARCH_SEARCH_INDEX')}_#{SecureRandom.uuid}" }
  let(:client) { OPENSEARCH_CLIENT }
  let(:retention_days) { ENV.fetch('OPENSEARCH_SEARCH_RETENTION_DAYS', 30).to_i }

  let(:old_time) { (retention_days + 1).days.ago.iso8601 }
  let(:new_time) { [(retention_days - 1), 0].max.days.ago.iso8601 }

  before do
    # Cleanup and Setup
    if client.indices.exists?(index: index_name)
      client.indices.delete(index: index_name)
    end
    client.indices.create(index: index_name)

    # Seed Data
  # 1 Old doc (older than retention), 1 New doc (within retention)
  client.index(index: index_name, id: 'os_old', body: { updated_at: old_time })
  client.index(index: index_name, id: 'os_new', body: { updated_at: new_time })

    # Critical: Refresh OpenSearch to make docs visible to query
    client.indices.refresh(index: index_name)
  end

  it 'successfully removes stale documents from Opensearch' do
    expect(client.count(index: index_name)['count']).to eq(2)

    # Run Job
    # Run the job; it will use the configured retention period (read from ENV
    # by the implementation). We seeded documents so one is older than
    # retention_days and should be deleted.
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

    result_count = client.count(index: index_name)['count']
    expect(result_count).to eq(1)
    
    # Ensure specific IDs were handled
    search_res = client.search(index: index_name, body: { query: { match_all: {} } })
    expect(search_res['hits']['hits']).not_to be_empty
    remaining_id = search_res['hits']['hits'].first['_id']
    expect(remaining_id).to eq('os_new')
  end
end
