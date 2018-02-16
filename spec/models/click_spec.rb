require 'spec_helper'

describe Click do
  fixtures :affiliates

  describe "#log(url, query, queried_at, click_ip, affiliate_name, position, results_source, vertical, locale, user_agent, model_id)" do
    it "should log almost-JSON info about the click" do
      expect(Rails.logger).to receive(:info) do |str|
        expect(str).to match(/^\[Click\] \{.*\}$/)
        expect(str).to include('"url":"http://www.fda.gov/foo.html"')
        expect(str).to include('"query":"my query"')
        expect(str).to include('"queried_at":"2000-01-01 20:15:01"')
        expect(str).to include('"click_ip":"12.34.56.789"')
        expect(str).to include('"affiliate_name":"someaff"')
        expect(str).to include('"position":"7"')
        expect(str).to include('"results_source":"RECALL"')
        expect(str).to include('"vertical":"web"')
        expect(str).to include('"locale":"en"')
        expect(str).to include('"user_agent":"mozilla"')
        expect(str).to include('"model_id":"123456"')
      end
      queried_at_str = Time.utc(2000, "jan", 1, 20, 15, 1).to_formatted_s(:db)
      Click.log("http://www.fda.gov/foo.html", "my query", queried_at_str, "12.34.56.789", "someaff", "7", "RECALL", "web", "en", "mozilla", "123456")
    end
  end
end
