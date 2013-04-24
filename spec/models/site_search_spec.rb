require 'spec_helper'

describe SiteSearch do
  fixtures :affiliates

  let(:affiliate) { affiliates(:power_affiliate) }
  let(:dc) do
    collection = affiliate.document_collections.build(
      :name => 'WH only',
      :url_prefixes_attributes => { '0' => { :prefix => 'http://www.whitehouse.gov/photos-and-video/' },
                                    '1' => { :prefix => 'http://www.whitehouse.gov/blog/' } })
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
    let(:bing_formatted_query) { mock("BingFormattedQuery", matching_site_limits: nil, query: 'ignore')}

    it 'should include sites from document collection' do
      BingFormattedQuery.should_receive(:new).with("gov", {:included_domains=>["www.whitehouse.gov/photos-and-video", "www.whitehouse.gov/blog"], :excluded_domains=>[], :scope_ids=>[], :scope_keywords=>[]}).and_return bing_formatted_query
      SiteSearch.new(:query => 'gov', :affiliate => affiliate, :document_collection => dc)
    end

    context 'when the affiliate has scope_keywords' do
      before { affiliate.update_attributes!(:scope_keywords => 'patents,america,flying inventions') }

      it 'should use the scope_keywords' do
        BingFormattedQuery.should_receive(:new).with("gov", {:included_domains=>["www.whitehouse.gov/photos-and-video", "www.whitehouse.gov/blog"], :excluded_domains=>[], :scope_ids=>[], :scope_keywords=>'patents,america,flying inventions'.split(',')}).and_return bing_formatted_query
        SiteSearch.new(:query => 'gov', :affiliate => affiliate, :document_collection => dc)
      end
    end

    context 'when the document collection has scope_keywords' do
      before do
        dc.update_attributes!(:scope_keywords => 'education , child development')
        affiliate.update_attributes!(:scope_keywords => '')
      end

      it 'should use the scope_keywords' do
        BingFormattedQuery.should_receive(:new).with("gov", {:included_domains=>["www.whitehouse.gov/photos-and-video", "www.whitehouse.gov/blog"], :excluded_domains=>[], :scope_ids=>[], :scope_keywords=>'education,child development'.split(',')}).and_return bing_formatted_query
        SiteSearch.new(:query => 'gov', :affiliate => affiliate, :document_collection => dc)
      end
    end

    context 'when affiliate and document collection has scope_keywords' do
      before do
        affiliate.update_attributes!(:scope_keywords => 'patents,america')
        dc.update_attributes!(:scope_keywords => 'patents,flying inventions')
      end

      it 'should use the document collection scope_keywords' do
        BingFormattedQuery.should_receive(:new).with("gov", {:included_domains=>["www.whitehouse.gov/photos-and-video", "www.whitehouse.gov/blog"], :excluded_domains=>[], :scope_ids=>[], :scope_keywords=>'patents,flying inventions'.split(',')}).and_return bing_formatted_query
        SiteSearch.new(:query => 'gov', :affiliate => affiliate, :document_collection => dc)
      end
    end
  end
end