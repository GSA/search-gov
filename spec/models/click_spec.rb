require 'spec/spec_helper'

describe Click do

  describe "#log(url, query, queried_at, click_ip, affiliate_name, position, results_source, vertical, locale, user_agent)" do
    it "should log almost-JSON info about the click" do
      Rails.logger.should_receive(:info) do |str|
        str.should match(/^\[Click\] \{.*\}$/)
        str.should include('"url":"http://www.fda.gov/foo.html"')
        str.should include('"query":"my query"')
        str.should include('"queried_at":"2000-01-01 20:15:01"')
        str.should include('"click_ip":"12.34.56.789"')
        str.should include('"affiliate_name":"someaff"')
        str.should include('"position":"7"')
        str.should include('"results_source":"RECALL"')
        str.should include('"vertical":"web"')
        str.should include('"locale":"en"')
        str.should include('"user_agent":"mozilla"')
      end
      queried_at_str = Time.utc(2000,"jan",1,20,15,1).to_formatted_s(:db)
      Click.log("http://www.fda.gov/foo.html","my query",queried_at_str, "12.34.56.789", "someaff","7","RECALL","web","en","mozilla")
    end

    context "when affiliate_name is null" do
      it "should assume it's the default affiliate and log that name" do
        Rails.logger.should_receive(:info).with(/\"affiliate_name\":\"#{Affiliate::USAGOV_AFFILIATE_NAME}\"/)
        Click.log("http://www.fda.gov/foo.html","my query",Time.now, "12.34.56.789", nil,"7","RECALL","web","en","mozilla")
      end
    end

  end
end
