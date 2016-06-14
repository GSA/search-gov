require 'spec_helper'

describe I14ySearch do
  fixtures :affiliates, :i14y_drawers, :i14y_memberships, :tag_filters

  let(:affiliate) { affiliates(:power_affiliate) }

  context 'when results are available' do
    let(:i14y_search) { I14ySearch.new(affiliate: affiliate, query: "marketplase", per_page: 20) }

    it "should return a response" do
      i14y_search.run
      i14y_search.startrecord.should == 1
      i14y_search.endrecord.should == 20
      i14y_search.total.should == 270
      i14y_search.spelling_suggestion.should == 'marketplace'
      first = i14y_search.results.first
      first.title.should == "Marketplace"
      first.link.should == 'https://www.healthcare.gov/glossary/marketplace'
      first.description.should == 'See Health Insurance Marketplace'
      first.body.should == 'More info on Health Insurance Marketplace'
    end
  end

  context 'when sort_by=date' do
    let(:i14y_search) { I14ySearch.new(affiliate: affiliate,
                                       sort_by: 'date',
                                       per_page: 20,
                                       query: 'marketplase') }

    it 'searches I14y with the appropriate params' do
      I14yCollections.should_receive(:search).with(hash_including(sort_by_date: 1))
      i14y_search.run
    end
  end

  context 'tag filters are present' do
    let(:affiliate_with_filter_tags) { affiliates(:basic_affiliate) }
    let(:i14y_search) { I14ySearch.new(affiliate: affiliate_with_filter_tags,
                                       per_page: 20,
                                       query: 'testing tag filters') }

    it 'searches I14y with the appropriate params' do
      I14yCollections.should_receive(:search).with(hash_including(ignore_tags: 'no way,nope', tags: 'important,must have'))
      i14y_search.run
    end
  end

  context 'when sort_by=date and tbs is specified' do
    let(:i14y_search) { I14ySearch.new(affiliate: affiliate,
                                       sort_by: 'date',
                                       tbs: 'm',
                                       per_page: 20,
                                       query: 'marketplase') }

    it 'searches I14y with the appropriate params' do
      I14yCollections.should_receive(:search).
        with(hash_including(sort_by_date: 1, min_timestamp: 1.send('month').ago.beginning_of_day))
      i14y_search.run
    end
  end

  context 'when sort_by=date and since_date and until_date are specified' do
    let(:i14y_search) { I14ySearch.new(affiliate: affiliate,
                                       sort_by: 'date',
                                       since_date: '07/28/2015',
                                       until_date: '09/28/2015',
                                       per_page: 20,
                                       query: 'marketplase') }

    it 'searches I14y with the appropriate params' do
      I14yCollections.should_receive(:search).
        with(hash_including(sort_by_date: 1, 
                            min_timestamp: DateTime.parse('07/28/2015').beginning_of_day,
                            max_timestamp: DateTime.parse('09/28/2015').end_of_day))
      i14y_search.run
    end
  end

  context 'when enable_highlighting is false' do
    let(:i14y_search) { I14ySearch.new(affiliate: affiliate,
                                       enable_highlighting: false,
                                       per_page: 20,
                                       query: 'marketplase') }

    it 'returns non highlighted results' do
      i14y_search.run

      first = i14y_search.results.first
      expect(first.title).to eq('Marketplace')
      expect(first.link).to eq('https://www.healthcare.gov/glossary/marketplace')
      expect(first.description).to eq('See Health Insurance Marketplace')
      expect(first.body).to eq('More info on Health Insurance Marketplace')
    end
  end

  context 'when there is some problem with the i14y client' do
    let(:i14y_search) { I14ySearch.new(affiliate: affiliate, query: "marketplace") }

    before do
      I14yCollections.stub(:search).and_raise Faraday::ClientError.new(Exception.new("problem"))
    end

    it "should log the error" do
      Rails.logger.should_receive(:error).with /I14y search problem/
      i14y_search.run
    end

  end

end
