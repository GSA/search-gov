require 'spec_helper'

describe I14ySearch do
  fixtures :affiliates, :i14y_drawers, :i14y_memberships

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
