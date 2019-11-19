# coding: utf-8
require 'spec_helper'

describe ElasticIndexedDocument do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    ElasticIndexedDocument.recreate_index
    affiliate.indexed_documents.delete_all
    affiliate.locale = 'en'
  end

  describe ".search_for" do
    describe "results structure" do
      context 'when there are results' do
        before do
          affiliate.indexed_documents.create!(title: 'Tropical Hurricane Names',
                                              description: 'This is a bunch of names',
                                              url: 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                              last_crawl_status: IndexedDocument::OK_STATUS)
          affiliate.indexed_documents.create!(title: 'More Hurricane names involving tropical',
                                              description: 'This is a bunch of other names',
                                              url: 'http://www.nhc.noaa.gov/aboutnames1.shtml',
                                              last_crawl_status: IndexedDocument::OK_STATUS)
          ElasticIndexedDocument.commit
        end

        it 'should return results in an easy to access structure' do
          search = ElasticIndexedDocument.search_for(q: 'Tropical', affiliate_id: affiliate.id, size: 1, offset: 1, language: affiliate.indexing_locale)
          expect(search.total).to eq(2)
          expect(search.results.size).to eq(1)
          expect(search.results.first).to be_instance_of(IndexedDocument)
          expect(search.offset).to eq(1)
        end

        context 'when those results get deleted' do
          before do
            affiliate.indexed_documents.destroy_all
            ElasticIndexedDocument.commit
          end

          it 'should return zero results' do
            search = ElasticIndexedDocument.search_for(q: 'hurricane', affiliate_id: affiliate.id, size: 1, offset: 1, language: affiliate.indexing_locale)
            expect(search.total).to be_zero
            expect(search.results.size).to be_zero
          end
        end
      end

    end
  end

  describe "highlighting results" do
    before do
      affiliate.indexed_documents.create!(title: 'Tropical Hurricane Names',
                                          description: 'Worldwide Tropical Cyclone Names',
                                          url: 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                          last_crawl_status: IndexedDocument::OK_STATUS)
      ElasticIndexedDocument.commit
    end

    context 'when no highlight param is sent in' do
      it 'should highlight appropriate fields with Bing highlighting' do
        search = ElasticIndexedDocument.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
        first = search.results.first
        expect(first.title).to eq("\uE000Tropical\uE001 Hurricane Names")
        expect(first.description).to eq("Worldwide \uE000Tropical\uE001 Cyclone Names")
      end
    end

    context 'when highlight is turned off' do
      it 'should not highlight matches' do
        search = ElasticIndexedDocument.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.indexing_locale, highlighting: false)
        first = search.results.first
        expect(first.title).to eq("Tropical Hurricane Names")
        expect(first.description).to eq("Worldwide Tropical Cyclone Names")
      end
    end

    context 'when title is really long' do
      before do
        long_title = "President Obama overcame furious lobbying by big banks to pass Dodd-Frank Wall Street Reform, to prevent the excessive risk-taking that led to a financial crisis while providing protections to American families for their mortgages and credit cards."
        affiliate.indexed_documents.create!(title: long_title,
                                            description: 'Worldwide Tropical Cyclone Names',
                                            url: 'http://www.nhc.noaa.gov/long.shtml',
                                            last_crawl_status: IndexedDocument::OK_STATUS)
        ElasticIndexedDocument.commit
      end

      it 'should show everything in a single fragment' do
        search = ElasticIndexedDocument.search_for(q: 'president credit cards', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
        first = search.results.first
        expect(first.title).to eq("\uE000President\uE001 Obama overcame furious lobbying by big banks to pass Dodd-Frank Wall Street Reform, to prevent the excessive risk-taking that led to a financial crisis while providing protections to American families for their mortgages and \uE000credit\uE001 \uE000cards\uE001.")
      end
    end

    context 'when description/body is really long' do
      before do
        long_text = ["President Obama overcame furious lobbying by big banks to pass Dodd-Frank Wall Street Reform, to prevent the excessive risk-taking that led to a financial crisis while providing protections to American families for their mortgages and credit cards.",
                     "This is just some filler text that will get ignored when making snippets. "*10,
                     "This sentence ends with President Obama.",
                     "Excessive risk-taking led to the financial crisis. "*10,
                     "And President Obama said some other stuff too."].join(' ').squish
        affiliate.indexed_documents.create!(title: 'Worldwide Tropical Cyclone Names',
                                            description: long_text,
                                            body: long_text,
                                            url: 'http://www.nhc.noaa.gov/long.shtml',
                                            last_crawl_status: IndexedDocument::OK_STATUS)
        ElasticIndexedDocument.commit
      end

      it 'shows everything in two 75 char fragments joined by ellipses' do
        search = ElasticIndexedDocument.search_for(q: 'president', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
        first = search.results.first
        ellipsized_results = "\uE000President\uE001 Obama overcame furious lobbying by big banks to pass Dodd-Frank Wall...snippets. This sentence ends with \uE000President\uE001 Obama. Excessive risk-taking led"
        expect(first.description).to eq(ellipsized_results)
        expect(first.body).to eq(ellipsized_results)
      end
    end
  end

  describe "filters" do
    context "when document collection is specified" do
      before do
        IndexedDocument.destroy_all
        @document_collection = affiliate.document_collections.create!(:name => "test",
                                                                      :url_prefixes_attributes => {
                                                                        '0' => { :prefix => 'http://www.agency.gov/' },
                                                                        '1' => { :prefix => 'http://www.nps.gov/' }
                                                                      })
        affiliate.site_domains.create!(:domain => "ignoreme.gov")
        IndexedDocument.create!(:last_crawl_status => IndexedDocument::OK_STATUS,
                                :title => 'Title 1',
                                :description => 'This is a HTML document.',
                                :url => 'http://www.nps.gov/html.html',
                                :affiliate_id => affiliate.id)
        IndexedDocument.create!(:last_crawl_status => IndexedDocument::OK_STATUS,
                                :title => 'Title 2',
                                :description => 'This is another HTML document.',
                                :url => 'http://www.ignoreme.gov/html.html',
                                :affiliate_id => affiliate.id)
        ElasticIndexedDocument.commit
      end

      it "should only return results from URLs matching prefixes from that collection" do
        search = ElasticIndexedDocument.search_for(q: 'document',
                                                   affiliate_id: affiliate.id,
                                                   language: affiliate.indexing_locale,
                                                   document_collection: @document_collection)
        expect(search.total).to eq(1)
        expect(search.results.first.title).to eq("Title 1")
        search = ElasticIndexedDocument.search_for(q: 'document',
                                                   affiliate_id: affiliate.id,
                                                   language: affiliate.indexing_locale)
        expect(search.total).to eq(2)
      end
    end

    context 'when there are matches across affiliates' do
      let(:other_affiliate) { affiliates(:power_affiliate) }

      before do
        other_affiliate.locale = 'en'
        values = { title: 'Tropical Hurricane Names',
                   description: 'Worldwide Tropical Cyclone Names',
                   url: 'http://www.nhc.noaa.gov/other.shtml',
                   last_crawl_status: IndexedDocument::OK_STATUS }
        affiliate.indexed_documents.create!(values)
        other_affiliate.indexed_documents.create!(values)

        ElasticIndexedDocument.commit
      end

      it "should return only matches for the given affiliate" do
        search = ElasticIndexedDocument.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
        expect(search.total).to eq(1)
        expect(search.results.first.affiliate.name).to eq(affiliate.name)
      end
    end

  end

  describe "recall" do
    before do
      affiliate.indexed_documents.create!(title: 'Obamå and Bideñ',
                                          description: 'Yosemite publications',
                                          body: 'spelling',
                                          url: 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                          last_crawl_status: IndexedDocument::OK_STATUS)
      ElasticIndexedDocument.commit
    end

    describe "title and description and body" do
      it 'should be case insentitive' do
        expect(ElasticIndexedDocument.search_for(q: 'OBAMå', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
        expect(ElasticIndexedDocument.search_for(q: 'yosemite', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
        expect(ElasticIndexedDocument.search_for(q: 'SpellinG', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
      end

      it 'performs ASCII folding' do
        expect(ElasticIndexedDocument.search_for(q: 'øbåmà', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
        expect(ElasticIndexedDocument.search_for(q: 'yøsemîte', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
        expect(ElasticIndexedDocument.search_for(q: 'spélliñg', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
      end

      context "when query only contains problem characters" do
        ['"   ', '   "       ', '+++', '+-', '-+'].each do |query|
          specify { expect(ElasticIndexedDocument.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to be_zero }
        end
      end

      context 'when query contains advanced elements like exact phrases and Booleans' do
        before do
          affiliate.indexed_documents.create!(title: 'This document is about Brad L. Miller and nobody else',
                                              description: 'Yosemite publications',
                                              body: 'some other text about dolphins',
                                              url: 'http://www.nhc.noaa.gov/testblm1.shtml',
                                              last_crawl_status: IndexedDocument::OK_STATUS)
          affiliate.indexed_documents.create!(title: 'This document has the letter L and is about another Brad Miller',
                                              description: 'yellowstone publications',
                                              body: 'some other text about whales',
                                              url: 'http://www.nhc.noaa.gov/testblm2.shtml',
                                              last_crawl_status: IndexedDocument::OK_STATUS)
          ElasticIndexedDocument.commit
        end

        it 'should use them to find documents using an implicit AND operator' do
          expect(ElasticIndexedDocument.search_for(q: '"Brad Miller"', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          expect(ElasticIndexedDocument.search_for(q: '"Brad L. Miller"', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          expect(ElasticIndexedDocument.search_for(q: 'Brad L. Miller', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(2)
          expect(ElasticIndexedDocument.search_for(q: 'Brad Miller porpoises', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(0)
          expect(ElasticIndexedDocument.search_for(q: '"other text" (porpoises OR whales)', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          expect(ElasticIndexedDocument.search_for(q: 'Brad Miller -yellowstone', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
        end

        context 'when query contains a wildcard' do
          it 'should find documents in the specified field based on truncation' do
            expect(ElasticIndexedDocument.search_for(q: 'dolphn*', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(0)
            expect(ElasticIndexedDocument.search_for(q: 'tx?', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(0)
            expect(ElasticIndexedDocument.search_for(q: 'dolph*', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
            expect(ElasticIndexedDocument.search_for(q: 'dolph?n', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
            expect(ElasticIndexedDocument.search_for(q: 'do*', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(2)
          end
        end
      end

      context 'when affiliate is English' do
        before do
          affiliate.indexed_documents.create!(title: 'The affiliate interns use powerful engineering computers',
                                              description: 'Organic feet symbolize with oceanic views',
                                              url: 'http://www.nhc.noaa.gov/aboutnames2.shtml',
                                              last_crawl_status: IndexedDocument::OK_STATUS)
          ElasticIndexedDocument.commit
        end

        it 'should do standard English stemming with basic stopwords' do
          appropriate_stemming = ['The computer with an internal and affiliates', 'Organics symbolizes a the view']
          appropriate_stemming.each do |query|
            expect(ElasticIndexedDocument.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          end
        end
      end

      context 'when affiliate is Spanish' do
        before do
          affiliate.locale = 'es'
          affiliate.indexed_documents.create!(title: 'Leyes y el rey',
                                              description: 'Beneficios y ayuda financiera verificación Lotería de visas 2015',
                                              url: 'http://www.nhc.noaa.gov/aboutnames2.shtml',
                                              last_crawl_status: IndexedDocument::OK_STATUS)
          ElasticIndexedDocument.commit
        end

        it 'should do minimal Spanish stemming with basic stopwords' do
          appropriate_stemming = ['ley con reyes', 'financieros']
          appropriate_stemming.each do |query|
            expect(ElasticIndexedDocument.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          end
          overstemmed_queries = %w{verificar finanzas}
          overstemmed_queries.each do |query|
            expect(ElasticIndexedDocument.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to be_zero
          end
        end

      end

      context 'when affiliate locale is not one of the custom indexed languages' do
        before do
          affiliate.locale = 'de'
          affiliate.indexed_documents.create!(title: 'Angebote und Superknüller der Woche',
                                              description: 'Angebote der Woche. Die Angebote der Woche sind gültig vom 30.03.2015 bis zum 04.04.2015.',
                                              url: 'http://el.wikipedia.org/wiki/valid_now',
                                              last_crawl_status: IndexedDocument::OK_STATUS)
          ElasticIndexedDocument.commit
        end

        it 'should do downcasing and ASCII folding only' do
          appropriate_stemming = ['superknuller', 'Gultig']
          appropriate_stemming.each do |query|
            expect(ElasticIndexedDocument.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          end
        end
      end

    end

  end

  it_behaves_like "an indexable"

end
