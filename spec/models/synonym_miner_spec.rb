require 'spec_helper'

describe SynonymMiner do
  fixtures :affiliates, :site_domains

  let(:affiliate) { affiliates(:basic_affiliate) }
  let(:synonym_miner) { SynonymMiner.new(affiliate, 3) }

  describe "#new" do
    before do
      affiliate.search_engine = 'Google'
    end

    it 'should ensure the affiliate search engine temporarily set to Bing' do
      affiliate.search_engine.should == 'Google'
      synonym_miner = SynonymMiner.new(affiliate)
      affiliate.search_engine.should == 'Bing'
    end
  end

  describe "#perform" do
    context 'when affiliate cannot be found' do
      it 'should log exception' do
        Rails.logger.should_receive(:warn)
        SynonymMiner.perform(-1,1)
      end
    end

    context 'when affiliate exists' do
      it 'should mine the synonyms for that site' do
        miner = mock(SynonymMiner)
        SynonymMiner.stub(:new).with(affiliate, 7).and_return miner
        miner.should_receive(:mine)
        SynonymMiner.perform(affiliate.id, 7)
      end
    end
  end

  describe ".mine" do
    before do
      synonym_miner.stub(:candidates).and_return([%w{abc alphabet}, %w{park parking}])
    end

    it "should attempt to create entries for synonym candidates" do
      Synonym.should_receive(:create_entry_for).with('abc, alphabet', affiliate)
      Synonym.should_receive(:create_entry_for).with('park, parking', affiliate)
      synonym_miner.mine
    end
  end

  describe ".popular_single_word_terms" do
    before do
      affiliate.sayt_suggestions.build(phrase: 'loren', popularity: 425)
      affiliate.sayt_suggestions.build(phrase: 'tax', popularity: 10000)
      affiliate.sayt_suggestions.build(phrase: 'tax extra words', popularity: 10000)
      affiliate.sayt_suggestions.build(phrase: 'bicycling', popularity: 10001)
      affiliate.save!
    end

    it 'should return the single-word terms from SaytSuggestions that have been updated in the last X days ordered by popularity' do
      synonym_miner.popular_single_word_terms.should == %w{bicycling tax loren}
    end
  end

  describe ".group_overlapping_sets" do
    context 'when the same token exists in more than one synonym sets' do
      let(:raw_synonym_sets) {
        [["nps.gov", "yosemite"], ["camp", "campers", "camping"], ["map", "maps"], ["job", "jobs"], ["webcam", "webcams"], ["everglades", "nps.gov"], ["lodge", "lodges", "lodging"], ["dog", "dogs"], ["nps.gov", "webcam", "webcams"], ["animal", "animals"], ["wedding", "weddings"], ["arch", "arches"], ["glacial", "glacier"], ["internship", "internships"], ["trail", "trails"], ["cabin", "cabins", "nps.gov"], ["sequoia", "sequoias"], ["hike", "hikes", "hiking"], ["redwood", "redwoods"], ["pass", "passes"], ["hunt", "hunters", "hunting"], ["career", "careers"], ["fish", "fishing"], ["plant", "plants"], ["snowshoe", "snowshoeing", "snowshoes"], ["campground", "campgrounds"], ["permit", "permits"], ["park", "parking"], ["video", "videos"], ["immigrant", "immigrants", "immigration"], ["biscayne", "nps.gov"], ["haleakala", "nps.gov"], ["climate", "climates"], ["passport", "passports"], ["florida", "nps.gov"], ["photo", "photos"], ["recreational vehicle", "rv"], ["hotel", "hotels"], ["fee", "fees"], ["bear", "bears"], ["cabin", "cabins"], ["hour", "hours"], ["locate", "located", "location", "locations"], ["hawai'i", "hawai`i", "hawaii"], ["christmas", "december 25"], ["reservation", "reservations"], ["manzanar", "nps.gov"], ["store", "stores"], ["activities", "activity", "nps.gov"], ["tour", "touring", "tours"], ["saguaro", "saguaros"], ["camp", "camper", "camping", "camps"], ["shop", "shops"], ["food", "foods"], ["james towne", "jamestown", "jamestowne"], ["backpack", "backpacker", "backpackers", "backpacking"], ["intern", "interns"], ["game", "games"]]
      }

      let(:raw_synonym_sets2) {
        [%w{house houses}, %w{tax taxes taxing taxed taxation}, %w{death taxes}, ['nps', 'national park service']]
      }

      it 'should combine them into alphabetized array of arrays where each token only appears in one array' do
        synonym_miner.group_overlapping_sets(raw_synonym_sets).should == [["activities", "activity", "biscayne", "cabin", "cabins", "everglades", "florida", "haleakala", "manzanar", "nps.gov", "webcam", "webcams", "yosemite"], ["animal", "animals"], ["arch", "arches"], ["backpack", "backpacker", "backpackers", "backpacking"], ["bear", "bears"], ["camp", "camper", "campers", "camping", "camps"], ["campground", "campgrounds"], ["career", "careers"], ["christmas", "december 25"], ["climate", "climates"], ["dog", "dogs"], ["fee", "fees"], ["fish", "fishing"], ["food", "foods"], ["game", "games"], ["glacial", "glacier"], ["hawai'i", "hawai`i", "hawaii"], ["hike", "hikes", "hiking"], ["hotel", "hotels"], ["hour", "hours"], ["hunt", "hunters", "hunting"], ["immigrant", "immigrants", "immigration"], ["intern", "interns"], ["internship", "internships"], ["james towne", "jamestown", "jamestowne"], ["job", "jobs"], ["locate", "located", "location", "locations"], ["lodge", "lodges", "lodging"], ["map", "maps"], ["park", "parking"], ["pass", "passes"], ["passport", "passports"], ["permit", "permits"], ["photo", "photos"], ["plant", "plants"], ["recreational vehicle", "rv"], ["redwood", "redwoods"], ["reservation", "reservations"], ["saguaro", "saguaros"], ["sequoia", "sequoias"], ["shop", "shops"], ["snowshoe", "snowshoeing", "snowshoes"], ["store", "stores"], ["tour", "touring", "tours"], ["trail", "trails"], ["video", "videos"], ["wedding", "weddings"]]
        synonym_miner.group_overlapping_sets(raw_synonym_sets2).should == [["death", "tax", "taxation", "taxed", "taxes", "taxing"],
                                                                           ["house", "houses"],
                                                                           ["nps", "national park service"]]
      end
    end
  end

  describe ".scrape_synonyms(queries)" do
    context 'when highlights exist in results for one or more terms' do
      let(:queries) { %w{christmas fishing haleakala gobbledegook} }

      before do
        synonym_miner.stub(:bing_site_search_results).and_return(
          [{ "title" => "\uE000Christmas\uE001 is on \uE000December 25\uE001", "content" => "\uE000December 25\uE001 is \uE000Christmas\uE001" },
           { "title" => "more \uE000Christmas\uE001 stuff", "content" => "more \uE000December 25\uE001 stuff about \uE000Christmas\uE001" }],
          [{ "title" => "\uE000fishing\uE001 is for \uE000fish\uE001", "content" => "go to a lake" }],
          [{ "title" => "\uE000haleakala\uE001", "content" => "no other word for it" }],
          [])
      end

      it 'should return unique sets of synonyms that contain more than one term' do
        synonym_miner.scrape_synonyms(queries).should == [["christmas", "december 25"], ["fish", "fishing"]]
      end
    end
  end

  describe ".site_search_results(query)" do
    let(:site_search) { mock(SiteSearch, results: [1, 2], run: nil) }

    before do
      SiteSearch.stub(:new).with(query: "foo", affiliate: affiliate, per_page: 20).and_return site_search
    end

    it 'should return 20 site search results for that affiliate on that query' do
      synonym_miner.bing_site_search_results('foo').should == [1, 2]
    end

  end

  describe ".candidates" do
    before do
      synonym_miner.stub(:popular_single_word_terms).and_return %w{houses taxation death nps}
      synonym_miner.stub(:scrape_synonyms).and_return [%w{house houses},
                                                       %w{tax taxes taxing taxed taxation},
                                                       %w{death taxes},
                                                       ['nps', 'national park service']]
    end

    it 'should return sets of possible synonym candidates for an affiliate' do
      synonym_miner.candidates.should == [["death", "tax", "taxation", "taxed", "taxes", "taxing"],
                                          ['nps', 'national park service']]
    end
  end

  describe ".filter_stemmed(singles)" do
    it 'should filter out single-words-only synonym sets (e.g., %w{house houses}) where all terms analyze to the same token' do
      synonym_miner.filter_stemmed([%w{house houses}, %w{tax taxes taxing taxed taxation}]).should == [%w{tax taxes taxing taxed taxation}]
    end
  end

  describe ".tokens_from_analyzer(synset)" do
    let(:gobiernousa_affiliate) { affiliates(:gobiernousa_affiliate) }
    let(:spanish_synonym_miner) { SynonymMiner.new(gobiernousa_affiliate) }

    it 'should return the unique analyzed tokens based on the input synonym set and the affiliate locale' do
      synonym_miner.tokens_from_analyzer(%w{tax taxes taxing taxed taxation}).should == %w{tax taxe taxing taxed taxation}
      synonym_miner.tokens_from_analyzer(%w{houses house}).should == %w{house}
      spanish_synonym_miner.tokens_from_analyzer(%w{visa visas}).should == %w{visa vis}
      spanish_synonym_miner.tokens_from_analyzer(%w{empleo empleos}).should == %w{emple}
    end
  end

  describe ".extract_highlights(field)" do
    context 'when highlight contains a affiliate site domain' do
      let(:field) { "\uE000nps.gov\uE001 stuff for \uE000irs\uE001" }

      it 'should strip it out' do
        affiliate.site_domains.first.domain.should == "nps.gov"
        synonym_miner.extract_highlights(field).should == ["irs"]
      end
    end

    context 'when highlight contains a possessive' do
      let(:field) { "\uE000irs's\uE001 stuff \uE000irs’s\uE001 stuff \uE000IRS’S\uE001 stuff " }

      it 'should strip it out' do
        synonym_miner.extract_highlights(field).should == ["irs", "irs", "irs"]
      end
    end

    context 'when highlight contains a comma' do
      let(:field) { "\uE000science, tech, engineering, and medicine\uE001 stuff \uE000stem\uE001" }

      it 'should strip it out' do
        synonym_miner.extract_highlights(field).should == ["science tech engineering and medicine", "stem"]
      end
    end

    context 'when highlight is a number' do
      let(:field) { "\uE00012,345\uE001 stuff \uE00031415\uE001" }

      it 'should strip it out' do
        synonym_miner.extract_highlights(field).should == []
      end
    end
  end
end
