require 'spec_helper'

describe QueryImpression do
  describe "#log(vertical, affiliate_name, query, modules)" do
    it "should log almost-JSON info about the query, including locale, vertical, affiliate, timestamp, piped modules shown, and the query" do
      time = Time.local(2000,"jan",1,20,15,1)
      Time.stub!(:now).and_return(time)
      Rails.logger.should_receive(:info) do |str|
        str.should match(/^\[Query Impression\] \{.*\}$/)
        str.should include('"modules":"BWEB|BSPEL"')
        str.should include('"affiliate":"usagov"')
        str.should include('"query":"my query"')
        str.should include('"vertical":"recall"')
        str.should include('"locale":"en"')
        str.should include('"time":"2000-01-01 20:15:01"')
      end
      QueryImpression.log(:recall, Affiliate::USAGOV_AFFILIATE_NAME, "my query", %w{BWEB BSPEL})
    end
  end
end
