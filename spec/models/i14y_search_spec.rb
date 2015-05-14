require 'spec_helper'

describe I14ySearch do
  fixtures :affiliates, :i14y_drawers

  let(:affiliate) { affiliates(:power_affiliate) }

  context 'when results are available' do
    let(:i14y_search) { I14ySearch.new(affiliate: affiliate, query: "marketplace") }

    it "should return a response" do
      i14y_search.run
      i14y_search.startrecord.should == 1
      i14y_search.endrecord.should == 20
      i14y_search.total.should == 270
      first = i14y_search.results.first
      first.title.should == "Marketplace"
      first.link.should == 'https://www.healthcare.gov/glossary/marketplace'
      first.description.should == 'See Health Insurance Marketplace'
      first.body.should == 'More info on Health Insurance Marketplace'
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
