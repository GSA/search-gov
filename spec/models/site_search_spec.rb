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
      SiteSearch.new(:query => 'gov', :affiliate => affiliate, :dc => dc.id).document_collection.should == dc
    end

    context 'when document collection max depth is >= 3' do
      before do
        dc.url_prefixes.create!(prefix: 'http://www.whitehouse.gov/seo/is/hard/')
        affiliate.search_engine.should == 'Bing'
      end

      subject { SiteSearch.new(:query => 'gov', :affiliate => affiliate, :dc => dc.id) }

      it 'should set the search engine to Google' do
        subject.affiliate.search_engine.should == 'Google'
      end
    end
  end

  describe '#run' do
    let(:bing_formatted_query) { mock("BingFormattedQuery", matching_site_limits: nil, query: 'ignore') }

    it 'should include sites from document collection' do
      BingFormattedQuery.should_receive(:new).with("gov", {:included_domains => ["www.whitehouse.gov/photos-and-video", "www.whitehouse.gov/blog"], :excluded_domains => []}).and_return bing_formatted_query
      SiteSearch.new(:query => 'gov', :affiliate => affiliate, :document_collection => dc)
    end

    context 'when no document collection is specified' do
      before do
        affiliate.site_domains.create(domain: 'usa.gov')
      end

      it 'should use the affiliate site domains for included domains instead' do
        BingFormattedQuery.should_receive(:new).with('gov',
                                                     {:included_domains => ["usa.gov"],
                                                      :excluded_domains => []}).and_return bing_formatted_query
        SiteSearch.new(:query => 'gov', :affiliate => affiliate)
      end
    end

  end
end