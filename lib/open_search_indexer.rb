# frozen_string_literal: true

class OpenSearchIndexer
  def self.create_index
    index_name = ENV.fetch('OPENSEARCH_INDEX')

    template_generator = SearchOpenSearch::Template.new("*#{index_name}*")

    OPENSEARCH_CLIENT.indices.put_template(
      body: template_generator.body,
      create: true,
      name: index_name,
      order: 0
    )

    repo = SearchOpenSearch::DocumentRepository.new
    repo.create_index!(index: index_name)
  end
end
