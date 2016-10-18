require 'spec_helper'

describe RtuReferrersRequest do
  fixtures :affiliates

  let(:site) { affiliates(:basic_affiliate) }
  let(:top_n) { [['url1', 10], ['url2', 5]] }
  let(:rtu_referrers_request) { RtuReferrersRequest.new("start_date" => "05/28/2014", "end_date" => "05/28/2014", "site" => site) }

  before do
    RtuDateRange.stub(:new).and_return double(RtuDateRange, available_dates_range: (Date.yesterday..Date.current))
    RtuTopQueries.stub(:new).and_return double(RtuTopQueries, top_n: top_n)
  end

  describe "#save" do
    it 'should return an array of [referrer url, count] sorted by desc referrer url count' do
      rtu_referrers_request.save
      rtu_referrers_request.top_referrers.should == top_n
    end
  end
end
