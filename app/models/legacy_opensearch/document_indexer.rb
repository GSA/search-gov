# frozen_string_literal: true

class LegacyOpenSearch::DocumentIndexer
  class DocumentIndexerError < StandardError; end
  class DuplicateID < DocumentIndexerError; end

  INDEX_NAME = ENV.fetch('LEGACY_OPENSEARCH_INDEX')

  # Indexes a document into OpenSearch. Accepts the same params shape as
  # SearchgovUrl#i14y_params. Uses Serde.serialize_hash to transform fields
  # (language-suffix renaming, HTML sanitization, array conversion, etc.)
  # before writing.
  #
  # This is an upsert: it creates the document if it doesn't exist, or
  # replaces it if it does. The i14y create/update distinction is unnecessary
  # here because SearchgovUrl#i14y_params always sends the full field set.
  def self.index(params)
    params = ActiveSupport::HashWithIndifferentAccess.new(params.deep_dup)
    document_id = params.delete(:document_id)
    language = params.delete(:language) || 'en'
    params.delete(:handle)

    raise DocumentIndexerError, 'document_id is required' if document_id.blank?

    params[:created_at] ||= Time.now.utc

    body = Serde.serialize_hash(params, language)
    body[:language] = language

    client.index(
      index: INDEX_NAME,
      id: document_id,
      body: body
    )
  rescue Elasticsearch::Transport::Transport::Errors::Conflict => e
    raise DuplicateID, e.message
  rescue Elasticsearch::Transport::Transport::Error => e
    Rails.logger.error "[LegacyOpenSearch::DocumentIndexer] Failed to index document #{document_id}: #{e.message}"
    raise DocumentIndexerError, e.message
  end

  def self.delete(document_id:, **_)
    client.delete(
      index: INDEX_NAME,
      id: document_id
    )
  rescue Elasticsearch::Transport::Transport::Errors::NotFound
    Rails.logger.warn "[LegacyOpenSearch::DocumentIndexer] Document not found for deletion: #{document_id}"
  rescue Elasticsearch::Transport::Transport::Error => e
    Rails.logger.error "[LegacyOpenSearch::DocumentIndexer] Failed to delete document #{document_id}: #{e.message}"
    raise DocumentIndexerError, e.message
  end

  def self.client
    OpenSearchConfig.search_client
  end
  private_class_method :client
end
