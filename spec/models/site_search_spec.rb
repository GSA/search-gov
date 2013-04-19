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
  end

  describe '#run' do

    let!(:web_search) { BingSearch.new }
    let(:search) { SiteSearch.new(:query => 'gov', :affiliate => affiliate, :document_collection => dc) }

    before do
      BoostedContent.should_not_receive(:search_for)
      BingSearch.should_receive(:new).and_return(bing_search)
    end

    it 'should include sites from document collection' do
      bing_search.should_receive(:query).
          with(%r[^\(gov\) \(site:www\.whitehouse\.gov/blog OR site:www\.whitehouse\.gov/photos-and-video\)$],
               anything(), anything(), anything(), anything(), anything()).
          and_return('')
      search.run
    end

    context 'when the query with URL prefixes are too long' do
      before do
        30.times do |i|
          dc.url_prefixes.create!(:prefix => "www.whitehouse.gov/the-press-office-news-releases/2012-day-#{i + 1}/")
        end
      end

      it 'should skip some of the longest URL prefixes' do
        bing_search.should_receive(:query).
            with(%r[site:#{Regexp.escape('www.whitehouse.gov/the-press-office-news-releases/2012-day-16)')}$],
                 anything(), anything(), anything(), anything(), anything()).
            and_return('')
        search.run
        search.formatted_query.length.should <= Search::QUERY_STRING_ALLOCATION
      end

      it 'should sort formatted query by length ASC, alnum DESC' do
        search.formatted_query.should =~ %r[^#{Regexp.escape('(gov) (site:www.whitehouse.gov/blog OR site:www.whitehouse.gov/photos-and-video')}]
        search.formatted_query.should =~ %r[#{Regexp.escape('www.whitehouse.gov/the-press-office-news-releases/2012-day-1 OR site:www.whitehouse.gov/the-press-office-news-releases/2012-day-30')}]
      end
    end

    context 'when the affiliate has scope_keywords' do
      before { affiliate.update_attributes!(:scope_keywords => 'patents,america,flying inventions') }

      it 'should use the scope_keywords' do
        bing_search.should_receive(:query).
            with(%r[^\(gov\) \("patents" OR "america" OR "flying inventions"\) \(site:www\.whitehouse\.gov/blog OR site:www\.whitehouse\.gov/photos-and-video\)$],
                 anything(), anything(), anything(), anything(), anything()).
            and_return('')
        search.run
      end
    end

    context 'when the document collection has scope_keywords' do
      before do
        dc.update_attributes!(:scope_keywords => 'education , child development')
        affiliate.update_attributes!(:scope_keywords => '')
      end

      it 'should use the scope_keywords' do
        bing_search.should_receive(:query).
            with(%r[^\(gov\) \("education" OR "child development"\) \(site:www\.whitehouse\.gov/blog OR site:www\.whitehouse\.gov/photos-and-video\)$],
                 anything(), anything(), anything(), anything(), anything()).
            and_return('')
        search.run
      end
    end

    context 'when affiliate and document collection has scope_keywords' do
      before do
        affiliate.update_attributes!(:scope_keywords => 'patents,america')
        dc.update_attributes!(:scope_keywords => 'patents,flying inventions')
      end

      it 'should use the document collection scope_keywords' do
        bing_search.should_receive(:query).
            with(%r[^\(gov\) \("patents" OR "flying inventions"\) \(site:www\.whitehouse\.gov/blog OR site:www\.whitehouse\.gov/photos-and-video\)$],
                 anything(), anything(), anything(), anything(), anything()).
            and_return('')
        search.run
      end
    end
  end
end