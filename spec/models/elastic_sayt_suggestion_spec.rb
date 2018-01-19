require 'spec_helper'

describe ElasticSaytSuggestion do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  before do
    ElasticSaytSuggestion.recreate_index
    affiliate.sayt_suggestions.delete_all
    affiliate.locale = 'en'
  end

  describe ".search_for" do
    describe "results structure" do
      context 'when there are results' do
        before do
          affiliate.sayt_suggestions.create!(phrase: 'hi suggest me', popularity: 30)
          affiliate.sayt_suggestions.create!(phrase: 'suggest me too', popularity: 29)
          affiliate.sayt_suggestions.create!(phrase: 'suggest me three suggests', popularity: 28)
          ElasticSaytSuggestion.commit
        end

        it 'should return results in an easy to access structure ordered by most popular' do
          search = ElasticSaytSuggestion.search_for(q: 'suggests', affiliate_id: affiliate.id, size: 1, offset: 1, language: affiliate.indexing_locale)
          search.total.should == 3
          search.results.size.should == 1
          search.results.first.should be_instance_of(SaytSuggestion)
          search.results.first.phrase.should =~ /me too/
          search.offset.should == 1
        end

        context 'when those results get deleted' do
          before do
            affiliate.sayt_suggestions.destroy_all
            ElasticSaytSuggestion.commit
          end

          it 'should return zero results' do
            search = ElasticSaytSuggestion.search_for(q: 'suggests', affiliate_id: affiliate.id, size: 1, offset: 1, language: affiliate.indexing_locale)
            search.total.should be_zero
            search.results.size.should be_zero
          end
        end
      end

    end
  end

  describe "highlighting results" do
    before do
      affiliate.sayt_suggestions.create!(phrase: 'hi suggest me', popularity: 30)
      ElasticSaytSuggestion.commit
    end

    context 'when no highlight param is sent in' do
      it 'should highlight appropriate fields with default highlighting' do
        search = ElasticSaytSuggestion.search_for(q: 'suggests', affiliate_id: affiliate.id, language: affiliate.indexing_locale)
        first = search.results.first
        first.phrase.should == "hi <strong>suggest</strong> me"
      end
    end

    context 'when highlight is turned off' do
      it 'should not highlight matches' do
        search = ElasticSaytSuggestion.search_for(q: 'suggests', affiliate_id: affiliate.id, language: affiliate.indexing_locale, highlighting: false)
        first = search.results.first
        first.phrase.should == "hi suggest me"
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
        first.phrase.should == "<strong>president</strong> obama overcame furious lobbying by big banks to pass dodd-<strong>frank</strong>"
      end
    end

  end

  describe "filters" do
    context 'when query is exact match of phrase' do
      before do
        affiliate.sayt_suggestions.create!(phrase: 'the exact match', popularity: 30)
        ElasticSaytSuggestion.commit
      end

      it "should ignore exact matches regardless of case" do
        ['the exact match', 'THE EXACT MATCH'].each do |query|
          ElasticSaytSuggestion.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total.should be_zero
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
        search.total.should == 1
        search.results.first.affiliate.name.should == affiliate.name
      end

    end

  end

  describe "recall" do
    before do
      affiliate.sayt_suggestions.create!(phrase: 'obama and biden', popularity: 30)
      ElasticSaytSuggestion.commit
    end

    describe "phrase" do
      it 'should be case insentitive' do
        ElasticSaytSuggestion.search_for(q: 'OBAMA', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total.should == 1
      end

      it 'should perform ASCII folding' do
        ElasticSaytSuggestion.search_for(q: 'øbåmà', affiliate_id: affiliate.id, language: affiliate.indexing_locale).total.should == 1
      end

      context "when query contains problem characters" do
        ['"   ', '   "       ', '+++', '+-', '-+'].each do |query|
          specify { ElasticSaytSuggestion.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total.should be_zero }
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
            ElasticSaytSuggestion.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total.should == 1
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
            ElasticSaytSuggestion.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total.should == 1
          end
          overstemmed_queries = %w{verificar finanzas}
          overstemmed_queries.each do |query|
            ElasticSaytSuggestion.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total.should be_zero
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
            ElasticSaytSuggestion.search_for(q: query, affiliate_id: affiliate.id, language: affiliate.indexing_locale).total.should == 1
          end
        end
      end

    end

  end

  it_behaves_like "an indexable"

end