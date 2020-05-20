require 'spec_helper'

describe Click do
  describe "#log" do
    it "should log almost-JSON info about the click" do
      expect(Rails.logger).to receive(:info) do |str|
        expect(str).to match(/^\[Click\] \{.*\}$/)
        expect(str).to include('"url":"http://www.fda.gov/foo.html"')
        expect(str).to include('"query":"my query"')
        expect(str).to include('"click_ip":"12.34.56.789"')
        expect(str).to include('"affiliate_name":"someaff"')
        expect(str).to include('"position":"7"')
        expect(str).to include('"results_source":"RECALL"')
        expect(str).to include('"vertical":"web"')
        expect(str).to include('"user_agent":"mozilla"')
      end
      Click.log("http://www.fda.gov/foo.html", "my query", "12.34.56.789", "someaff", "7", "RECALL", "web", "mozilla")
    end
  end
end
