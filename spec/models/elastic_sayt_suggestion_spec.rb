require 'spec_helper'

describe ElasticSaytSuggestion do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:search_params) do
    {
      q: 'suggest',
      affiliate_id: affiliate.id,
      size: 1,
      offset: 0,
      language: affiliate.indexing_locale
    }
  end
  let(:search) { ElasticSaytSuggestion.search_for(search_params) }

  before do
    ElasticSaytSuggestion.recreate_index
    affiliate.sayt_suggestions.delete_all
    affiliate.locale = 'en'
  end

  describe '.search_for' do
    describe 'results structure' do
      context 'when there are results' do
        before do
          affiliate.sayt_suggestions.create!(phrase: 'suggest me first', popularity: 30)
          affiliate.sayt_suggestions.create!(phrase: 'suggest me too', popularity: 29)
          affiliate.sayt_suggestions.create!(phrase: 'suggest me three suggests', popularity: 28)
          ElasticSaytSuggestion.commit
        end

        it 'returns results in an easy to access structure ordered by most popular' do
          expect(search.total).to eq(3)
          expect(search.results.size).to eq(1)
          expect(search.results.first).to be_instance_of(SaytSuggestion)
          expect(search.results.first.phrase).to match(/first/)
          expect(search.offset).to eq(0)
        end

        context 'when those results get deleted' do
          before do
            affiliate.sayt_suggestions.destroy_all
            ElasticSaytSuggestion.commit
          end

          it 'should return zero results' do
            expect(search.total).to be_zero
            expect(search.results.size).to be_zero
          end
        end

        context 'when an offset is specified' do
          let(:search) do
            ElasticSaytSuggestion.search_for(search_params.merge(offset: 1))
          end

          it 'returns results with the specified offset' do
            expect(search.offset).to eq(1)
            expect(search.results.first.phrase).to match(/me too/)
          end
        end
      end
    end
  end

  describe 'highlighting results' do
    before do
      affiliate.sayt_suggestions.create!(phrase: 'hi suggest me', popularity: 30)
      ElasticSaytSuggestion.commit
    end

    context 'when no highlight param is sent in' do
      let(:search) do
        ElasticSaytSuggestion.search_for(search_params.except(:highlighting))
      end

      it 'should highlight appropriate fields with default highlighting' do
        first = search.results.first
        expect(first.phrase).to eq("hi <strong>suggest</strong> me")
      end
    end

    context 'when highlight is turned off' do
      let(:search) do
        ElasticSaytSuggestion.search_for(search_params.merge(highlighting: false))
      end

      it 'should not highlight matches' do
        first = search.results.first
        expect(first.phrase).to eq("hi suggest me")
      end
    end

    context 'when phrase is really long' do
      before do
        long_phrase = "president obama overcame furious lobbying by big banks to pass dodd-frank"
        affiliate.sayt_suggestions.create!(phrase: long_phrase, popularity: 30)
        ElasticSaytSuggestion.commit
      end

      it 'should show everything in a single fragment' do
        search = ElasticSaytSuggestion.search_for(q: 'president frank', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
        first = search.results.first
        expect(first.phrase).to eq("<strong>president</strong> obama overcame furious lobbying by big banks to pass dodd-<strong>frank</strong>")
      end
    end

  end

  describe 'filters' do
    context 'when query is exact match of phrase' do
      before do
        affiliate.sayt_suggestions.create!(phrase: 'the exact match', popularity: 30)
        ElasticSaytSuggestion.commit
      end

      # Temporarily disabling these specs during ES56 upgrade
      # https://cm-jira.usa.gov/browse/SRCH-838
      it 'ignores exact matches regardless of case' do
        ['the exact match', 'THE EXACT MATCH'].each do |query|
          expect(ElasticSaytSuggestion.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to be_zero
        end
      end
    end

    context 'when there are matches across affiliates' do
      let(:other_affiliate) { affiliates(:power_affiliate) }

      before do
        other_affiliate.locale = 'en'
        values = { phrase: 'tropical hurricane names', popularity: 20 }
        affiliate.sayt_suggestions.create!(values)
        other_affiliate.sayt_suggestions.create!(values)

        ElasticSaytSuggestion.commit
      end

      it "should return only matches for the given affiliate" do
        search = ElasticSaytSuggestion.search_for(q: 'Tropical', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
        expect(search.total).to eq(1)
        expect(search.results.first.affiliate.name).to eq(affiliate.name)
      end

    end

  end

  describe 'recall' do
    before do
      affiliate.sayt_suggestions.create!(phrase: 'obama and biden', popularity: 30)
      ElasticSaytSuggestion.commit
    end

    describe "phrase" do
      it 'should be case insentitive' do
        expect(ElasticSaytSuggestion.search_for(q: 'OBAMA', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
      end

      it 'should perform ASCII folding' do
        expect(ElasticSaytSuggestion.search_for(q: 'øbåmà', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
      end

      context "when query contains problem characters" do
        ['"   ', '   "       ', '+++', '+-', '-+'].each do |query|
          specify { expect(ElasticSaytSuggestion.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to be_zero }
        end
      end

      context 'when affiliate is English' do
        before do
          affiliate.sayt_suggestions.create!(phrase: 'the affiliate interns use powerful engineering computers', popularity: 45)
          affiliate.sayt_suggestions.create!(phrase: 'organic feet symbolize with oceanic views', popularity: 44)
          ElasticSaytSuggestion.commit
        end

        it 'should do standard English stemming with basic stopwords' do
          appropriate_stemming = ['The computer with an internal and affiliates', 'Organics symbolizes a the view']
          appropriate_stemming.each do |query|
            expect(ElasticSaytSuggestion.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          end
        end
      end

      context 'when affiliate is Spanish' do
        before do
          affiliate.locale = 'es'
          affiliate.sayt_suggestions.create!(phrase: 'Leyes y el rey', popularity: 45)
          affiliate.sayt_suggestions.create!(phrase: 'Beneficios y ayuda financiera verificación Lotería de visas 2015', popularity: 44)
          ElasticSaytSuggestion.commit
        end

        it 'should do minimal Spanish stemming with basic stopwords' do
          appropriate_stemming = ['ley con reyes', 'financieros']
          appropriate_stemming.each do |query|
            expect(ElasticSaytSuggestion.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          end
          overstemmed_queries = %w{verificar finanzas}
          overstemmed_queries.each do |query|
            expect(ElasticSaytSuggestion.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to be_zero
          end
        end

      end

      context 'when affiliate locale is not one of the custom indexed languages' do
        before do
          affiliate.locale = 'de'
          affiliate.sayt_suggestions.create!(phrase: 'Angebote und Superknüller der Woche', popularity: 45)
          affiliate.sayt_suggestions.create!(phrase: 'Angebote der Woche. Die Angebote der Woche sind gültig', popularity: 44)
          ElasticSaytSuggestion.commit
        end

        it 'should do downcasing and ASCII folding only' do
          appropriate_stemming = ['superknuller', 'Gultig']
          appropriate_stemming.each do |query|
            expect(ElasticSaytSuggestion.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total).to eq(1)
          end
        end
      end

    end

  end

  it_behaves_like "an indexable"

end
