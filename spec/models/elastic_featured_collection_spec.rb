# coding: utf-8
require 'spec_helper'

describe ElasticFeaturedCollection do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:search_params) do
    {
      q: 'Tropical',
      affiliate_id: affiliate.id,
      language: affiliate.indexing_locale
    }
  end

  before do
    ElasticFeaturedCollection.recreate_index
    affiliate.featured_collections.delete_all
    affiliate.locale = 'en'
  end

  describe ".search_for" do
    describe "results structure" do
      context 'when there are results' do
        before do
          affiliate.featured_collections.create!(title: 'Tropical Hurricane Names',
                                                 status: 'active',
                                                 publish_start_on: Date.current)
          affiliate.featured_collections.create!(title: 'More Hurricane names involving tropical',
                                                 status: 'active',
                                                 publish_start_on: Date.current)
          ElasticFeaturedCollection.commit
        end

        it 'should return results in an easy to access structure' do
          search = ElasticFeaturedCollection.search_for(q: 'Tropical', affiliate_id: affiliate.id, size: 1, offset: 1, language: affiliate.indexing_locale)
          expect(search.total).to eq(2)
          expect(search.results.size).to eq(1)
          expect(search.results.first).to be_instance_of(FeaturedCollection)
          expect(search.offset).to eq(1)
        end

        context 'when those results get deleted' do
          before do
            affiliate.featured_collections.destroy_all
            ElasticFeaturedCollection.commit
          end

          it 'should return zero results' do
            search = ElasticFeaturedCollection.search_for(q: 'hurricane', affiliate_id: affiliate.id, size: 1, offset: 1, language: affiliate.indexing_locale)
            expect(search.total).to be_zero
            expect(search.results.size).to be_zero
          end
        end
      end

    end
  end

  describe 'highlighting results' do
    before do
      featured_collection = affiliate.featured_collections.build(title: 'Tropical Hurricane Names',
                                                                 status: 'active',
                                                                 publish_start_on: Date.current)
      featured_collection.featured_collection_links.build(title: 'Worldwide Tropical Cyclone Names Part1',
                                                          url: 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                                          position: '0')
      featured_collection.featured_collection_links.build(title: 'Worldwide Tropical Cyclone Names Part2',
                                                          url: 'http://www.nhc.noaa.gov/aboutnames2.shtml',
                                                          position: '1')
      featured_collection.save!
      ElasticFeaturedCollection.commit
    end

    context 'when no highlight param is sent in' do
      it 'should highlight appropriate fields with <strong> by default' do
        search = ElasticFeaturedCollection.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
        first = search.results.first
        expect(first.title).to eq("<strong>Tropical</strong> Hurricane Names")
        first.featured_collection_links.each do |fcl|
          expect(fcl.title).to match(%r(Worldwide <strong>Tropical</strong>))
        end
      end
    end

    context 'when field has HTML entity like an ampersand' do
      before do
        featured_collection = affiliate.featured_collections.build(title: 'Peas & Carrots',
                                                                   status: 'active',
                                                                   publish_start_on: Date.current)
        featured_collection.featured_collection_links.build(title: 'highlighting and entities',
                                                            url: 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                                            position: '0')
        featured_collection.save!
        ElasticFeaturedCollection.commit
      end

      it 'should escape the entity but show the highlight' do
        search = ElasticFeaturedCollection.search_for(search_params.merge(q: 'carrots'))
        first = search.results.first
        expect(first.title).to eq("Peas &amp; <strong>Carrots</strong>")
        search = ElasticFeaturedCollection.search_for(search_params.merge(q: 'entities'))
        first = search.results.first
        expect(first.title).to eq("Peas &amp; Carrots")
      end
    end

    context 'when highlight is turned off' do
      it 'should not highlight matches' do
        search = ElasticFeaturedCollection.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.indexing_locale, highlighting: false)
        first = search.results.first
        expect(first.title).to eq("Tropical Hurricane Names")
        first.featured_collection_links.each do |fcl|
          expect(fcl.title).to match(%r(Worldwide Tropical Cyclone))
        end
      end
    end

    context 'when title is really long' do
      before do
        long_title = "President Obama overcame furious lobbying by big banks to pass Dodd-Frank Wall Street Reform, to prevent the excessive risk-taking that led to a financial crisis while providing protections to American families for their mortgages and credit cards."
        affiliate.featured_collections.create!(title: long_title, status: 'active', publish_start_on: Date.current)
        ElasticFeaturedCollection.commit
      end

      it 'should show everything in a single fragment' do
        search = ElasticFeaturedCollection.search_for(q: 'president credit cards', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
        first = search.results.first
        expect(first.title).to eq("<strong>President</strong> Obama overcame furious lobbying by big banks to pass Dodd-Frank Wall Street Reform, to prevent the excessive risk-taking that led to a financial crisis while providing protections to American families for their mortgages and <strong>credit</strong> <strong>cards</strong>.")
      end
    end
  end

  describe "filters" do
    context "when there are active and inactive featured collections" do
      before do
        affiliate.featured_collections.create!(title: 'Tropical Hurricane Names', status: 'active',
                                               publish_start_on: Date.current)
        affiliate.featured_collections.create!(title: 'Retired Tropical Hurricane names', status: 'inactive',
                                               publish_start_on: Date.current)
        ElasticFeaturedCollection.commit
      end

      it "should return only active Featured Collections" do
        search = ElasticFeaturedCollection.search_for(q: 'Tropical', affiliate_id: affiliate.id, size: 2, language: affiliate.indexing_locale)
        expect(search.total).to eq(1)
        expect(search.results.first.is_active?).to be true
      end
    end

    context 'when there are matches across affiliates' do
      let(:other_affiliate) { affiliates(:power_affiliate) }

      before do
        other_affiliate.locale = 'en'
        values = { title: 'Tropical Hurricane Names', status: 'active', publish_start_on: Date.current }
        affiliate.featured_collections.create!(values)
        other_affiliate.featured_collections.create!(values)

        ElasticFeaturedCollection.commit
      end

      it "should return only matches for the given affiliate" do
        search = ElasticFeaturedCollection.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
        expect(search.total).to eq(1)
        expect(search.results.first.affiliate.name).to eq(affiliate.name)
      end
    end

    context 'when publish_start_on date has not been reached' do
      before do
        affiliate.featured_collections.create!(title: 'Current Tropical Hurricane Names', status: 'active',
                                               publish_start_on: Date.current)
        affiliate.featured_collections.create!(title: 'Future Tropical Hurricane names', status: 'active',
                                               publish_start_on: Date.tomorrow)
        ElasticFeaturedCollection.commit
      end

      it 'should omit those results' do
        search = ElasticFeaturedCollection.search_for(q: 'Tropical', affiliate_id: affiliate.id, size: 2, language: affiliate.indexing_locale)
        expect(search.total).to eq(1)
        expect(search.results.first.title).to match(/^Current/)
      end
    end

    context 'when publish_end_on date has been reached' do
      before do
        affiliate.featured_collections.create!(title: 'Current Tropical Hurricane Names', status: 'active',
                                               publish_start_on: Date.current)
        affiliate.featured_collections.create!(title: 'Expired Tropical Hurricane names', status: 'active',
                                               publish_start_on: 1.week.ago.to_date, publish_end_on: Date.current)
        ElasticFeaturedCollection.commit
      end

      it 'should omit those results' do
        search = ElasticFeaturedCollection.search_for(q: 'Tropical', affiliate_id: affiliate.id, size: 2, language: affiliate.indexing_locale)
        expect(search.total).to eq(1)
        expect(search.results.first.title).to match(/^Current/)
      end
    end
  end

  describe 'recall' do
    let(:valid_fc_params) do
      {
        title: 'Obamå',
        status: 'active',
        publish_start_on: Date.current,
      }
    end
    let(:fc_params) { valid_fc_params }

    before do
      featured_collection = affiliate.featured_collections.build(fc_params)
      featured_collection.featured_collection_links.build(title: 'Bideñ',
                                                          url: 'http://www.nhc.noaa.gov/aboutnames2.shtml',
                                                          position: 0)
      featured_collection.featured_collection_links.build(title: 'Our affiliates and customers are terrible at spelling',
                                                          url: 'http://www.nhc.noaa.gov/aboutnames3.shtml',
                                                          position: 1)
      featured_collection.featured_collection_links.build(title: 'Especially park names like yosemite',
                                                          url: 'http://www.nhc.noaa.gov/aboutname43.shtml',
                                                          position: 2)
      featured_collection.featured_collection_links.build(title: 'And the occasional similar spanish/english word like publications',
                                                          url: 'http://www.nhc.noaa.gov/aboutname4.shtml',
                                                          position: 3)
      featured_collection.featured_collection_keywords.build(value: 'Corazón')
      featured_collection.featured_collection_keywords.build(value: 'fair pay act')
      featured_collection.save!
      ElasticFeaturedCollection.commit
    end

    context 'when I search on terms that are only present in the title or description' do
      let(:search) { ElasticFeaturedCollection.search_for(q: 'Obama', affiliate_id: affiliate.id, language: affiliate.indexing_locale) }

      it 'should return the matches from the title or description' do
        expect(search.total).to eq(1)
        expect(search.results.size).to eq(1)
      end

      context 'when match_keyword_values_only is true' do
        let(:fc_params) { valid_fc_params.merge({ match_keyword_values_only: true }) }
        it 'should not return the matches from the title or description' do
          expect(search.total).to eq(0)
          expect(search.results.size).to eq(0)
        end
      end
    end

    describe 'keywords' do
      it 'should be case insensitive' do
        expect(ElasticFeaturedCollection.search_for(q: 'cORAzon', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
      end

      it 'should perform ASCII folding' do
        expect(ElasticFeaturedCollection.search_for(q: 'coràzon', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
      end

      it 'should only match full keyword phrase' do
        expect(ElasticFeaturedCollection.search_for(q: 'fair pay act', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
        expect(ElasticFeaturedCollection.search_for(q: 'fair pay', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to be_zero
      end
    end

    describe "title and link titles" do
      it 'should be case insentitive' do
        expect(ElasticFeaturedCollection.search_for(q: 'OBAMA', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
        expect(ElasticFeaturedCollection.search_for(q: 'BIDEN', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
      end

      it 'should perform ASCII folding' do
        expect(ElasticFeaturedCollection.search_for(q: 'øbåmà', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
        expect(ElasticFeaturedCollection.search_for(q: 'bîdéÑ', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
      end

      context "when query contains problem characters" do
        ['"   ', '   "       ', '+++', '+-', '-+'].each do |query|
          specify { expect(ElasticFeaturedCollection.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to be_zero }
        end

        %w(+++obama --obama +-obama).each do |query|
          specify { expect(ElasticFeaturedCollection.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1) }
        end
      end

      context 'when affiliate is English' do
        before do
          featured_collection = affiliate.featured_collections.build(title: 'The affiliate interns use powerful engineering computers',
                                                                     status: 'active',
                                                                     publish_start_on: Date.current)
          featured_collection.featured_collection_links.build(title: 'Organic feet symbolize with oceanic views',
                                                              url: 'http://www.nhc.noaa.gov/aboutnames2.shtml',
                                                              position: 0)
          featured_collection.save!
          ElasticFeaturedCollection.commit
        end

        it 'should do standard English stemming with basic stopwords' do
          appropriate_stemming = ['The computer with an internal and affiliates', 'Organics symbolizes a the view']
          appropriate_stemming.each do |query|
            expect(ElasticFeaturedCollection.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          end
        end
      end

      context 'when affiliate is Spanish' do
        before do
          affiliate.locale = 'es'
          featured_collection = affiliate.featured_collections.build(title: 'Leyes y el rey',
                                                                     status: 'active',
                                                                     publish_start_on: Date.current)
          featured_collection.featured_collection_links.build(title: 'Beneficios y ayuda financiera verificación',
                                                              url: 'http://www.nhc.noaa.gov/aboutnames2.shtml',
                                                              position: 0)
          featured_collection.featured_collection_links.build(title: 'Lotería de visas 2015',
                                                              url: 'http://www.nhc.noaa.gov/aboutnames3.shtml',
                                                              position: 1)
          featured_collection.save!
          ElasticFeaturedCollection.commit
        end

        it 'should do minimal Spanish stemming with basic stopwords' do
          appropriate_stemming = ['ley con reyes', 'financieros']
          appropriate_stemming.each do |query|
            expect(ElasticFeaturedCollection.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          end
          overstemmed_queries = %w{verificar finanzas}
          overstemmed_queries.each do |query|
            expect(ElasticFeaturedCollection.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to be_zero
          end
        end
      end

      context 'when affiliate locale is not one of the custom indexed languages' do
        before do
          affiliate.locale = 'de'
          featured_collection = affiliate.featured_collections.build(title: 'Angebote und Superknüller der Woche',
                                                                     status: 'active',
                                                                     publish_start_on: Date.current)
          featured_collection.featured_collection_links.build(title: 'Angebote der Woche. Die Angebote der Woche sind gültig vom 30.03.2015 bis zum 04.04.2015.',
                                                              url: 'http://el.wikipedia.org/wiki/Είναι',
                                                              position: 0)
          featured_collection.save!
          ElasticFeaturedCollection.commit
        end

        it 'should do downcasing and ASCII folding only' do
          appropriate_stemming = ['superknuller', 'Gultig']
          appropriate_stemming.each do |query|
            expect(ElasticFeaturedCollection.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          end
        end
      end

    end
  end

  it_behaves_like "an indexable"

end
