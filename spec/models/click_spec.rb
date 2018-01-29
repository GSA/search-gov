require 'spec_helper'

describe Click do
  fixtures :affiliates

  describe "#log(url, query, queried_at, click_ip, affiliate_name, position, results_source, vertical, locale, user_agent, model_id)" do
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
        str.should include('"model_id":"123456"')
      end
      queried_at_str = Time.utc(2000, "jan", 1, 20, 15, 1).to_formatted_s(:db)
      Click.log("http://www.fda.gov/foo.html", "my query", queried_at_str, "12.34.56.789", "someaff", "7", "RECALL", "web", "en", "mozilla", "123456")
    end
  end
end
