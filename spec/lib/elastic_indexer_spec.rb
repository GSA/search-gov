require 'spec_helper'

describe ElasticIndexer do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    ElasticIndexedDocument.recreate_index
    affiliate.indexed_documents.destroy_all
    affiliate.locale = 'en'
    affiliate.indexed_documents.create!(title: 'Tropical Hurricane Names',
                                        description: 'This is a bunch of names',
                                        url: 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                        last_crawl_status: IndexedDocument::OK_STATUS)
    affiliate.indexed_documents.create!(title: 'More Hurricane names involving tropical',
                                        description: 'This is a bunch of other names',
                                        url: 'http://www.nhc.noaa.gov/aboutnames1.shtml',
                                        last_crawl_status: IndexedDocument::SUMMARIZED_STATUS)
    affiliate.indexed_documents.create!(title: 'tropical document',
                                        description: 'This document is not really there so do not index it',
                                        url: 'http://www.nhc.noaa.gov/404.shtml',
                                        last_crawl_status: '404')
    affiliate.indexed_documents.create!(title: 'another failed tropical document',
                                        description: 'This document is also not really there so do not index it',
                                        url: 'http://www.nhc.noaa.gov/404_2.shtml',
                                        last_crawl_status: '404')
  end

  describe '#index_all' do
    it "should index all valid instances" do
      ElasticIndexer.index_all("IndexedDocument")
      ElasticIndexedDocument.commit
      search = ElasticIndexedDocument.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
      expect(search.total).to eq(2)
    end

    it "should make use of available optimizing includes" do
      featured_collection = double(FeaturedCollection)
      expect(featured_collection).to receive(:find_in_batches).with(batch_size: ElasticIndexer::DEFAULT_BATCH_SIZE)
      expect(FeaturedCollection).to receive(:includes).with(ElasticFeaturedCollection::OPTIMIZING_INCLUDES).and_return(featured_collection)
      ElasticIndexer.index_all("FeaturedCollection")

      indexed_document = double(IndexedDocument)
      expect(indexed_document).to receive(:find_in_batches).with(batch_size: ElasticIndexer::DEFAULT_BATCH_SIZE)
      expect(IndexedDocument).to receive(:includes).with(nil).and_return(indexed_document)
      ElasticIndexer.index_all("IndexedDocument")
    end

    context 'when data payload is empty' do
      before do
        affiliate.indexed_documents.ok.destroy_all
        affiliate.indexed_documents.summarized.destroy_all
      end

      it 'should not index anything' do
        expect(ElasticIndexedDocument).not_to receive(:index)
        ElasticIndexer.index_all("IndexedDocument")
      end
    end
  end
end
