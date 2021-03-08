require 'spec_helper'

describe ElasticMigrateReader do
  describe '#perform' do
    it 'should migrate the reader alias' do
      expect(ElasticIndexedDocument).to receive(:migrate_reader)
      ElasticMigrateReader.perform('IndexedDocument')
    end
  end
end