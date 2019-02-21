require 'spec_helper'

describe SiteSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:power_affiliate) }
  let(:dc) do
    collection = affiliate.document_collections.build(
      :name => 'WH only',
      :url_prefixes_attributes => {'0' => {:prefix => 'http://www.whitehouse.gov/photos-and-video/'},
                                   '1' => {:prefix => 'http://www.whitehouse.gov/blog/'}})
    collection.save!
    collection.navigation.update_attributes!(:is_active => true)
    collection
  end

  describe ".initialize" do
    it "should use the dc param to find a document collection when document_collection isn't present" do
      expect(SiteSearch.new(:query => 'gov', :affiliate => affiliate, :dc => dc.id).document_collection).to eq(dc)
    end
  end

  describe '#run' do
    let(:bing_formatted_query) { double("BingFormattedQuery", matching_site_limits: nil, query: 'ignore') }

    it 'should include sites from document collection' do
      expect(BingV7FormattedQuery).to receive(:new).with(
        "gov", hash_including(included_domains: ["www.whitehouse.gov/photos-and-video/", "www.whitehouse.gov/blog/"],
                              excluded_domains: [])).and_return bing_formatted_query
      SiteSearch.new(:query => 'gov', :affiliate => affiliate, :document_collection => dc)
    end

    context 'when no document collection is specified' do
      before do
        affiliate.site_domains.create(domain: 'usa.gov')
        expect(BingV7FormattedQuery).to receive(:new).with(
          'gov', hash_including(included_domains: ["usa.gov"], excluded_domains: [])
        ).and_return bing_formatted_query
      end

      subject { SiteSearch.new(:query => 'gov', :affiliate => affiliate) }
      its(:sitelink_generator_names) { should be_nil }
    end

    context 'when commercial spelling suggestion is present' do
      let(:affiliate) { affiliates(:usagov_affiliate) }
      let(:collection) do
        coll = affiliate.document_collections.build(
          :name => 'WH only',
          :url_prefixes_attributes => {'0' => { prefix: 'www.whitehouse.gov' }})
        coll.save!
        coll.navigation.update_attributes!(:is_active => true)
        coll
      end

      it 'includes BSPEL and OVER in the modules' do
        search = SiteSearch.new({ affiliate: affiliate, document_collection: collection, query: 'militry' })
        search.run
        expect(search.modules).to include('BSPEL', 'OVER')
      end
    end

    context 'when matching document and DG Search spelling suggestion are present' do
      let(:collection) do
        coll = affiliate.document_collections.build(
          :name => 'WH only',
          :url_prefixes_attributes => {'0' => { prefix: 'www100.whitehouse.gov' }})
        coll.save!
        coll.navigation.update_attributes!(:is_active => true)
        coll
      end

      before do
        ElasticIndexedDocument.recreate_index
        IndexedDocument.create!(affiliate: affiliate,
                                title: 'electro coagulation',
                                description: 'Scientists created a technology to remove contaminants',
                                url: 'http://www100.whitehouse.gov/electro-coagulation',
                                last_crawl_status: IndexedDocument::OK_STATUS)
        ElasticIndexedDocument.commit
      end

      it 'includes SPEL and LOVER in the modules' do
        search = SiteSearch.new({ affiliate: affiliate, document_collection: collection, query: 'Scientost' })
        search.run
        expect(search.modules).to include('SPEL', 'LOVER')
      end
    end

    context 'when matching document is not present' do
      let(:collection) do
        coll = affiliate.document_collections.build(
          :name => 'WH only',
          :url_prefixes_attributes => {'0' => { prefix: 'www100.whitehouse.gov' }})
        coll.save!
        coll.navigation.update_attributes!(:is_active => true)
        coll
      end

      before do
        ElasticIndexedDocument.recreate_index
        IndexedDocument.create!(affiliate: affiliates(:usagov_affiliate),
                                title: 'electro coagulation',
                                description: 'Scientists created a technology to remove contaminants',
                                url: 'http://www100.whitehouse.gov/electro-coagulation',
                                last_crawl_status: IndexedDocument::OK_STATUS)
        ElasticIndexedDocument.commit
      end

      it 'excludes SPEL and LOVER from the modules' do
        search = SiteSearch.new({ affiliate: affiliate, document_collection: collection, query: 'Scientost' })
        search.run
        expect(search.modules).not_to include('SPEL', 'LOVER')
      end
    end
  end
end
