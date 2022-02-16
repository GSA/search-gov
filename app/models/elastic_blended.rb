# frozen_string_literal: true

class ElasticBlended
  #Note: keep these alphabetized
  INDEXES = %w{IndexedDocument NewsItem}

  extend Indexable

  def self.reader_alias
    @blended_indexes ||= INDEXES.map { |model_name| "Elastic#{model_name}".constantize.reader_alias }
  end

  def self.index_type
    @blended_types ||= INDEXES.map { |model_name| "Elastic#{model_name}".underscore }
  end

end
