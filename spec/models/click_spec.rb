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

    context 'when it is some sort of boosted content click' do
      context 'when affiliate exists' do
        let(:affiliate) { affiliates(:basic_affiliate) }

        it 'should publish BOOS click info to Keen' do
          keen_hash = { :affiliate_id => affiliate.id, :module => 'BOOS', :url => "http://www.fda.gov/foo.html", :query => "my query", :model_id => "123456" }
          KeenBestBetLogger.should_receive(:log).with(:clicks, keen_hash)
          Click.log("http://www.fda.gov/foo.html", "my query", Time.now, "12.34.56.789", affiliate.name, "7", "BOOS", "web", "en", "mozilla", "123456")
        end

        it 'should publish BBG click info to Keen' do
          keen_hash = { :affiliate_id => affiliate.id, :module => 'BBG', :url => "http://www.fda.gov/foo.html", :query => "my query", :model_id => "123456" }
          KeenBestBetLogger.should_receive(:log).with(:clicks, keen_hash)
          Click.log("http://www.fda.gov/foo.html", "my query", Time.now, "12.34.56.789", affiliate.name, "7", "BBG", "web", "en", "mozilla", "123456")
        end
      end

      context 'when affiliate does not exist' do
        it 'should not publish click info to Keen' do
          KeenBestBetLogger.should_not_receive(:log)
          Click.log("http://www.fda.gov/foo.html", "my query", Time.now, "12.34.56.789", 'does not exist', "7", "BBG", "web", "en", "mozilla", "123456")
        end
      end
    end
  end
end
