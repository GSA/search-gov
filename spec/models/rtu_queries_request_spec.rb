require 'spec_helper'

describe RtuQueriesRequest do
  fixtures :affiliates

  before do
    RtuDateRange.stub(:new).and_return mock(RtuDateRange, available_dates_range: (Date.yesterday..Date.current))
  end

  let(:site) { affiliates(:basic_affiliate) }

  describe "#save" do
    describe "computing top query stats" do
      let(:rtu_queries_request) { RtuQueriesRequest.new("start_date" => "05/28/2014",
                                                        "end_date" => "05/28/2014",
                                                        "query" => "mexico petition marine",
                                                        "site" => site) }

      context "when stats available" do
        let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/rtu_queries_request.json")) }

        before do
          query_body = %q({"query":{"filtered":{"query":{"match":{"query":{"query":"mexico petition marine","analyzer":"snowball","operator":"and"}}},"filter":{"bool":{"must":[{"term":{"affiliate":"nps.gov"}},{"range":{"@timestamp":{"gte":"2014-05-28","lte":"2014-05-28"}}}],"must_not":{"term":{"useragent.device":"Spider"}}}}}},"aggs":{"agg":{"terms":{"field":"raw","size":1000},"aggs":{"type":{"terms":{"field":"type"}}}}}})
          opts = {index: "logstash-*", type: %w(search click), body: query_body, size: 0}
          ES::client_reader.should_receive(:search).with(opts).and_return json_response
          rtu_queries_request.save
        end

        it 'should return an array of QueryClickCount objects sorted by desc query count' do
          arr = rtu_queries_request.top_queries.map { |qcc| [qcc.query, qcc.queries, qcc.clicks, qcc.ctr] }
          arr.should == [["petition for marine held in mexico", 7, 2, 28.0],
                         ["petition for us marine jailed in mexico", 4, 0, 0.0],
                         ["marine in mexico petition", 2, 3, 150.0],
                         ["petition for marine jailed in mexico", 1, 1, 100.0]]
        end

      end

      context 'when stats unavailable' do
        before do
          ES::client_reader.stub(:search).and_raise StandardError
          rtu_queries_request.save
        end

        it 'should return nil' do
          rtu_queries_request.top_queries.should be_nil
        end
      end
    end

    describe "start and end dates" do
      before do
        ES::client_reader.stub(:search).and_raise StandardError
      end
      context "when both end_date and start_date are specified" do
        let(:rtu_queries_request) { RtuQueriesRequest.new("start_date" => "05/27/2014",
                                                          "end_date" => "05/28/2014",
                                                          "query" => "mexico petition marine",
                                                          "site" => site) }
        before do
          rtu_queries_request.save
        end

        it 'should use them' do
          rtu_queries_request.start_date.should == Date.parse("05/27/2014")
          rtu_queries_request.end_date.should == Date.parse("05/28/2014")
        end
      end

      context "when end_date is not specified" do
        let(:rtu_queries_request) { RtuQueriesRequest.new("start_date" => "05/27/2014",
                                                          "query" => "mexico petition marine",
                                                          "site" => site) }
        before do
          rtu_queries_request.save
        end

        it 'should use end of available dates range' do
          rtu_queries_request.end_date.should == Date.current
        end
      end

      context "when neither is specified" do
        let(:rtu_queries_request) { RtuQueriesRequest.new("query" => "mexico petition marine", "site" => site) }

        before do
          rtu_queries_request.save
        end

        it 'should use beginning of month of available dates range' do
          rtu_queries_request.start_date.should == Date.current.beginning_of_month
        end
      end
    end

  end
end