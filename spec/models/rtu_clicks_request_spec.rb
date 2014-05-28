require 'spec_helper'

describe RtuClicksRequest do
  fixtures :affiliates

  before do
    RtuDateRange.stub(:new).and_return mock(RtuDateRange, available_dates_range: (Date.yesterday..Date.current))
  end

  let(:site) { affiliates(:basic_affiliate) }

  describe "#save" do
    describe "computing top url stats" do
      let(:rtu_clicks_request) { RtuClicksRequest.new("start_date" => "05/28/2014", "end_date" => "05/28/2014", "site" => site) }

      context "when url stats available" do
        let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/top_urls.json")) }

        before do
          ES::client_reader.stub(:search).and_return json_response
          rtu_clicks_request.save
        end

        it 'should return an array of [url, count] sorted by desc url count' do
          rtu_clicks_request.top_urls.should == [["http://appropriations.house.gov/subcommittees/subcommittee/?IssueID=34776", 10],
                                                 ["http://assembly.ca.gov/legislativebranch", 9],
                                                 ["http://cs.cpsc.gov/ConceptDemo/SearchCPSC.aspx?SearchCategory=Recalls+-+Home+Maintenance+and+Structures&category=995%2c1098&subcategory=308&query=kenmore+35+pint+dehumidifiers", 8],
                                                 ["http://livertox.nih.gov/AloeVera.htm", 7],
                                                 ["http://search.usa.gov/search?affiliate=usagov&m=true&query=%2Bhigher+ratingfor+prostate+cancer+jan2014+feb2014+site%3Ava.gov", 6],
                                                 ["http://www.americaslibrary.gov/aa/twain/aa_twain_huckfinn_1.html", 5],
                                                 ["http://www.dol.gov/ebsa/faqs/faq_911_2.html", 4],
                                                 ["http://www.dot.ca.gov/", 3],
                                                 ["http://www.fbi.gov/stats-services/publications/law-enforcement-bulletin/february2011/february-2011-leb.pdf", 2],
                                                 ["http://www.marines.mil/Portals/59/Publications/FMFRP%2012-18%20%20Mao%20Tse-tung%20on%20Guerrilla%20Warfare.pdf", 1]]
        end

      end

      context 'when stats unavailable' do
        before do
          ES::client_reader.stub(:search).and_raise StandardError
          rtu_clicks_request.save
        end

        it 'should return nil' do
          rtu_clicks_request.top_urls.should be_nil
        end
      end
    end

  end
end