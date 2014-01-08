require 'spec_helper'

describe ElasticResqueIndexer do
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
    ElasticIndexedDocument.commit

  end

  describe '#index_all' do
    it "should queue up indexing of all valid instances" do
      start_id = IndexedDocument.minimum(:id)
      end_id = IndexedDocument.maximum(:id)
      Resque.should_receive(:enqueue).with(ElasticResqueIndexer, "IndexedDocument", start_id, end_id)
      ElasticResqueIndexer.index_all("IndexedDocument")
    end

  end

  describe '#perform' do
    it "should index all valid instances in some ID range" do
      start_id = IndexedDocument.minimum(:id)
      end_id = IndexedDocument.maximum(:id)
      ElasticResqueIndexer.perform("IndexedDocument", start_id, end_id)
      search = ElasticIndexedDocument.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.locale)
      search.total.should == 2
    end
  end

end