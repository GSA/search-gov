# coding: utf-8
require 'spec_helper'

describe ElasticBoostedContent do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:query) { 'Tropical' }
  let(:search_params) do
    {
      q: query,
      affiliate_id: affiliate.id,
      size: 1,
      offset: 0,
      language: affiliate.indexing_locale
    }
  end
  let(:search) { ElasticBoostedContent.search_for(search_params) }

  before do
    ElasticBoostedContent.recreate_index
    affiliate.boosted_contents.delete_all
    affiliate.locale = 'en'
  end

  describe ".search_for" do
    describe "results structure" do
      context 'when there are results' do
        before do
          affiliate.boosted_contents.create!(title: 'Tropical Hurricane Names',
                                             description: 'This is a bunch of names',
                                             url: 'https://secure.nhc.noaa.gov/aboutnames.shtml',
                                             status: 'active',
                                             publish_start_on: Date.current)
          affiliate.boosted_contents.create!(title: 'More Hurricane names',
                                             description: 'This is a bunch of other names including the word tropical',
                                             url: 'http://www.nhc.noaa.gov/aboutnames1.shtml',
                                             status: 'active',
                                             publish_start_on: Date.current)
          ElasticBoostedContent.commit
        end

        it 'should return results in an easy to access structure' do
          search = ElasticBoostedContent.search_for(q: 'Tropical', affiliate_id: affiliate.id, size: 1, offset: 1, language: affiliate.indexing_locale)
          expect(search.total).to eq(2)
          expect(search.results.size).to eq(1)
          expect(search.results.first).to be_instance_of(BoostedContent)
          expect(search.offset).to eq(1)
        end

        context 'when site_limits option is present' do
          it 'returns results with matching URL prefix' do
            search = ElasticBoostedContent.search_for(q: 'Tropical',
                                                      affiliate_id: affiliate.id,
                                                      size: 1,
                                                      offset: 0,
                                                      language: affiliate.indexing_locale,
                                                      site_limits: %w(secure.nhc.noaa.gov blog.noaa.gov))
            expect(search.total).to eq(1)
            expect(search.results.first.title).to eq('<strong>Tropical</strong> Hurricane Names')
          end
        end

        context 'when those results get deleted' do
          before do
            affiliate.boosted_contents.destroy_all
            ElasticBoostedContent.commit
          end

          it 'should return zero results' do
            search = ElasticBoostedContent.search_for(q: 'hurricane', affiliate_id: affiliate.id, size: 1, offset: 1, language: affiliate.indexing_locale)
            expect(search.total).to be_zero
            expect(search.results.size).to be_zero
          end
        end
      end

    end
  end

  describe 'highlighting results' do
    before do
      affiliate.boosted_contents.create!(title: 'Tropical Hurricane Names',
                                         status: 'active',
                                         description: 'Worldwide Tropical Cyclone Names',
                                         url: 'http://www.nhc.noaa.gov/aboutnames.shtml',
                                         publish_start_on: Date.current)
      ElasticBoostedContent.commit
    end

    context 'when no highlight param is sent in' do
      let(:search) do
        ElasticBoostedContent.search_for(search_params.except(:highlighting))
      end

      it 'highlights appropriate fields with <strong> by default' do
        first = search.results.first
        expect(first.title).to eq("<strong>Tropical</strong> Hurricane Names")
        expect(first.description).to eq("Worldwide <strong>Tropical</strong> Cyclone Names")
      end
    end

    context 'when field has HTML entity like an ampersand' do
      let(:query) { 'carrots' }

      before do
        affiliate.boosted_contents.create!(title: 'Peas & Carrots',
                                           status: 'active',
                                           description: 'html entities',
                                           url: 'http://www.nhc.noaa.gov/peas.shtml',
                                           publish_start_on: Date.current)
        ElasticBoostedContent.commit
      end

      it 'escapes the entity but shows the highlight' do
        first = search.results.first
        expect(first.title).to eq("Peas &amp; <strong>Carrots</strong>")
      end
    end

    context 'when highlight is turned off' do
      let(:search) do
        ElasticBoostedContent.search_for(search_params.merge(highlighting: false))
      end

      it 'should not highlight matches' do
        first = search.results.first
        expect(first.title).to eq("Tropical Hurricane Names")
        expect(first.description).to eq("Worldwide Tropical Cyclone Names")
      end
    end

    context 'when title is really long' do
      before do
        long_title = "President Obama overcame furious lobbying by big banks to pass Dodd-Frank Wall Street Reform, to prevent the excessive risk-taking that led to a financial crisis while providing protections to American families for their mortgages and credit cards."
        affiliate.boosted_contents.create!(title: long_title,
                                           status: 'active',
                                           description: 'Worldwide Tropical Cyclone Names',
                                           url: 'http://www.nhc.noaa.gov/long.shtml',
                                           publish_start_on: Date.current)
        ElasticBoostedContent.commit
      end

      it 'should show everything in a single fragment' do
        search = ElasticBoostedContent.search_for(q: 'president credit cards', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
        first = search.results.first
        expect(first.title).to eq("<strong>President</strong> Obama overcame furious lobbying by big banks to pass Dodd-Frank Wall Street Reform, to prevent the excessive risk-taking that led to a financial crisis while providing protections to American families for their mortgages and <strong>credit</strong> <strong>cards</strong>.")
      end
    end
  end

  describe "filters" do
    context "when there are active and inactive boosted contents" do
      before do
        affiliate.boosted_contents.create!(title: 'Tropical Hurricane Names',
                                           status: 'active',
                                           description: 'Worldwide Tropical Cyclone Names',
                                           url: 'http://www.nhc.noaa.gov/active.shtml',
                                           publish_start_on: Date.current)
        affiliate.boosted_contents.create!(title: 'Retired Tropical Hurricane names',
                                           status: 'inactive',
                                           description: 'Retired Worldwide Tropical Cyclone Names',
                                           url: 'http://www.nhc.noaa.gov/inactive.shtml',
                                           publish_start_on: Date.current)
        ElasticBoostedContent.commit
      end

      it "should return only active boosted contents" do
        search = ElasticBoostedContent.search_for(q: 'Tropical', affiliate_id: affiliate.id, size: 2, language: affiliate.indexing_locale)
        expect(search.total).to eq(1)
        expect(search.results.first.is_active?).to be true
      end
    end

    context 'when there are matches across affiliates' do
      let(:other_affiliate) { affiliates(:power_affiliate) }

      before do
        other_affiliate.locale = 'en'
        values = { title: 'Tropical Hurricane Names',
                   status: 'active',
                   description: 'Worldwide Tropical Cyclone Names',
                   url: 'http://www.nhc.noaa.gov/other.shtml',
                   publish_start_on: Date.current }
        affiliate.boosted_contents.create!(values)
        other_affiliate.boosted_contents.create!(values)

        ElasticBoostedContent.commit
      end

      it "should return only matches for the given affiliate" do
        search = ElasticBoostedContent.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
        expect(search.total).to eq(1)
        expect(search.results.first.affiliate.name).to eq(affiliate.name)
      end
    end

    context 'when publish_start_on date has not been reached' do
      before do
        affiliate.boosted_contents.create!(title: 'Current Tropical Hurricane Names',
                                           status: 'active',
                                           description: 'Worldwide Tropical Cyclone Names',
                                           url: 'http://www.nhc.noaa.gov/current.shtml',
                                           publish_start_on: Date.current)
        affiliate.boosted_contents.create!(title: 'Future Tropical Hurricane names',
                                           status: 'active',
                                           description: 'Tomorrow Worldwide Tropical Cyclone Names',
                                           url: 'http://www.nhc.noaa.gov/tomorrow.shtml',
                                           publish_start_on: Date.tomorrow)
        ElasticBoostedContent.commit
      end

      it 'should omit those results' do
        search = ElasticBoostedContent.search_for(q: 'Tropical', affiliate_id: affiliate.id, size: 2, language: affiliate.indexing_locale)
        expect(search.total).to eq(1)
        expect(search.results.first.title).to match(/^Current/)
      end
    end

    context 'when publish_end_on date has been reached' do
      before do
        affiliate.boosted_contents.create!(title: 'Current Tropical Hurricane Names',
                                           status: 'active',
                                           description: 'Worldwide Tropical Cyclone Names',
                                           url: 'http://www.nhc.noaa.gov/current.shtml',
                                           publish_start_on: Date.current)
        affiliate.boosted_contents.create!(title: 'Future Tropical Hurricane names',
                                           status: 'active',
                                           description: 'Tomorrow Worldwide Tropical Cyclone Names',
                                           url: 'http://www.nhc.noaa.gov/tomorrow.shtml',
                                           publish_start_on: 1.week.ago.to_date,
                                           publish_end_on: Date.current)
        ElasticBoostedContent.commit
      end

      it 'should omit those results' do
        search = ElasticBoostedContent.search_for(q: 'Tropical', affiliate_id: affiliate.id, size: 2, language: affiliate.indexing_locale)
        expect(search.total).to eq(1)
        expect(search.results.first.title).to match(/^Current/)
      end
    end
  end

  describe 'recall' do
    let(:valid_bc_params) do
      {
        title: 'Obamå and Bideñ',
        status: 'active',
        description: 'Yosemite publication spelling',
        url: 'http://www.nhc.noaa.gov/aboutnames.shtml',
        publish_start_on: Date.current
      }
    end
    let(:bc_params) { valid_bc_params }

    before do
      boosted_content = affiliate.boosted_contents.build(bc_params)
      boosted_content.boosted_content_keywords.build(value: 'Corazón')
      boosted_content.boosted_content_keywords.build(value: 'fair pay act')
      boosted_content.save!
      ElasticBoostedContent.commit
    end

    context 'when I search on terms that are only present in the title or description' do
      let(:search) { ElasticBoostedContent.search_for(q: 'yosemite publication', affiliate_id: affiliate.id, language: affiliate.indexing_locale) }

      it 'should return the matches from the title or description' do
        expect(search.total).to eq(1)
        expect(search.results.size).to eq(1)
      end

      context 'when match_keyword_values_only is true' do
        let(:bc_params) { valid_bc_params.merge({ match_keyword_values_only: true }) }
        it 'should not return the matches from the title or description' do
          expect(search.total).to eq(0)
          expect(search.results.size).to eq(0)
        end
      end
    end

    context 'when various apostrophes are present in title/desc/keywords' do
      before do
        apostrophe_1 = affiliate.boosted_contents.build(title: "hawai`i o'reilly",
                                                           status: 'active',
                                                           description: "ignore them",
                                                           url: 'http://www.nhc.noaa.gov/hi1.shtml',
                                                           publish_start_on: Date.current)
        apostrophe_1.save!
        apostrophe_2 = affiliate.boosted_contents.build(title: "island",
                                                           status: 'active',
                                                           description: "Hawaiʻi's language orthography has it's own special characters",
                                                           url: 'http://www.nhc.noaa.gov/hi2.shtml',
                                                           publish_start_on: Date.current)
        apostrophe_2.save!
        apostrophe_3 = affiliate.boosted_contents.build(title: "loren's island",
                                                           status: 'active',
                                                           description: 'paradise',
                                                           url: 'http://www.nhc.noaa.gov/hi3.shtml',
                                                           publish_start_on: Date.current)
        apostrophe_3.boosted_content_keywords.build(value: "Hawai'i")
        apostrophe_3.save!
        ElasticBoostedContent.commit
      end

      it 'should ignore them' do
        expect(ElasticBoostedContent.search_for(q: "oreilly", affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
        expect(ElasticBoostedContent.search_for(q: 'hawaii', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(3)
        expect(ElasticBoostedContent.search_for(q: 'hawai`i', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(3)
        expect(ElasticBoostedContent.search_for(q: "hawai'i orthography", affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
        expect(ElasticBoostedContent.search_for(q: "lorens", affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
      end
    end

    describe 'keywords' do
      it 'should be case insensitive' do
        expect(ElasticBoostedContent.search_for(q: 'cORAzon', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
      end

      it 'should perform ASCII folding' do
        expect(ElasticBoostedContent.search_for(q: 'coràzon', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
      end

      it 'should only match full keyword phrase' do
        expect(ElasticBoostedContent.search_for(q: 'fair pay act', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
        expect(ElasticBoostedContent.search_for(q: 'fair pay', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to be_zero
      end
    end

    describe "title and description" do
      it 'is case insentitive' do
        expect(ElasticBoostedContent.search_for(search_params.merge(q: 'YOSEMITE')).total).
          to eq(1)
      end

      it 'should perform ASCII folding' do
        expect(ElasticBoostedContent.search_for(q: 'øbåmà', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
        expect(ElasticBoostedContent.search_for(q: 'bîdéÑ', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
      end

      context 'when query contains problem characters' do
        ['"   ', '   "       ', '+++', '+-', '-+'].each do |query|
          specify do
            expect(ElasticBoostedContent.search_for(search_params.merge(q: query)).total).
              to be_zero
          end
        end

        %w(+++yosemite --yosemite +-yosemite).each do |query|
          specify do
            expect(ElasticBoostedContent.search_for(search_params.merge(q: query)).total).
              to eq(1)
          end
        end
      end

      context 'when affiliate is English' do
        before do
          affiliate.boosted_contents.create!(title: 'The affiliate interns use powerful engineering computers',
                                             status: 'active',
                                             description: 'Organic feet symbolize with oceanic views',
                                             url: 'http://www.nhc.noaa.gov/aboutnames2.shtml',
                                             publish_start_on: Date.current)
          ElasticBoostedContent.commit
        end

        it 'should do standard English stemming with basic stopwords' do
          appropriate_stemming = ['The computer with an internal and affiliates', 'Organics symbolizes a the view']
          appropriate_stemming.each do |query|
            expect(ElasticBoostedContent.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          end
        end
      end

      context 'when affiliate is Spanish' do
        before do
          affiliate.locale = 'es'
          affiliate.boosted_contents.create!(title: 'Leyes y el rey',
                                             status: 'active',
                                             description: 'Beneficios y ayuda financiera verificación Lotería de visas 2015',
                                             url: 'http://www.nhc.noaa.gov/aboutnames2.shtml',
                                             publish_start_on: Date.current)
          ElasticBoostedContent.commit
        end

        it 'should do minimal Spanish stemming with basic stopwords' do
          appropriate_stemming = ['ley con reyes', 'financieros']
          appropriate_stemming.each do |query|
            expect(ElasticBoostedContent.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          end
          overstemmed_queries = %w{verificar finanzas}
          overstemmed_queries.each do |query|
            expect(ElasticBoostedContent.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to be_zero
          end
        end
      end

      context 'when affiliate locale is not one of the custom indexed languages' do
        before do
          affiliate.locale = 'de'
          affiliate.boosted_contents.create!(title: 'Angebote und Superknüller der Woche',
                                             status: 'active',
                                             description: 'Angebote der Woche. Die Angebote der Woche sind gültig vom 30.03.2015 bis zum 04.04.2015.',
                                             url: 'http://el.wikipedia.org/wiki/Είναι',
                                             publish_start_on: Date.current)
          ElasticBoostedContent.commit
        end

        it 'should do downcasing and ASCII folding only' do
          appropriate_stemming = ['superknuller', 'Gultig']
          appropriate_stemming.each do |query|
            expect(ElasticBoostedContent.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          end
        end
      end
    end

  end

  it_behaves_like "an indexable"

end
