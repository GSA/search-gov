require 'spec_helper'

describe RtuClicksRequest do
  fixtures :affiliates

  let(:site) { affiliates(:basic_affiliate) }
  let(:top_n) { [['url1', 10], ['url2', 5]] }
  let(:rtu_clicks_request) { RtuClicksRequest.new("start_date" => "05/28/2014", "end_date" => "05/28/2014", "site" => site) }

  before do
    RtuDateRange.stub(:new).and_return mock(RtuDateRange, available_dates_range: (Date.yesterday..Date.current))
    RtuTopClicks.stub(:new).and_return mock(RtuTopClicks, top_n: top_n)
  end

  describe "#save" do
    it 'should return an array of [url, count] sorted by desc url count' do
      rtu_clicks_request.save
      rtu_clicks_request.top_urls.should == top_n
    end
  end
end