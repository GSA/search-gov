require 'spec_helper'

describe RtuQueriesRequest do
  fixtures :affiliates

  before do
    RtuDateRange.stub(:new).and_return double(
      RtuDateRange, available_dates_range: (Date.yesterday..Date.current),
      default_start: Date.yesterday.beginning_of_month,
      default_end: Date.current
    )
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
          opts = { index: "logstash-*", type: %w(search click), body: query_body, size: 0 }
          ES::client_reader.should_receive(:search).with(opts).and_return json_response
        end

        it 'should return an array of QueryClickCount objects sorted by desc query count' do
          rtu_queries_request.save
          arr = rtu_queries_request.top_queries.map { |qcc| [qcc.query, qcc.queries, qcc.clicks, qcc.ctr, qcc.is_routed_query] }
          arr.should == [["petition for marine held in mexico", 7, 2, 28.0, false],
                         ["petition for us marine jailed in mexico", 4, 0, 0.0, false],
                         ["marine in mexico petition", 2, 3, 150.0, false],
                         ["petition for marine jailed in mexico", 1, 1, 100.0, false]]
        end

        context 'matching routed queries exist' do
          before do
            site.routed_queries.create!(description: 'Some desc',
                                        url: 'http://www.gov.gov/url.html',
                                        routed_query_keywords_attributes: { '0' => { 'keyword' => 'marine in mexico petition' } })
          end

          it 'should return an array of QueryClickCount objects with is_routed_query set to true, sorted by desc query count' do
            rtu_queries_request.save
            arr = rtu_queries_request.top_queries.map { |qcc| [qcc.query, qcc.queries, qcc.clicks, qcc.ctr, qcc.is_routed_query] }
            arr.should == [["petition for marine held in mexico", 7, 2, 28.0, false],
                           ["petition for us marine jailed in mexico", 4, 0, 0.0, false],
                           ["marine in mexico petition", 2, 3, 150.0, true],
                           ["petition for marine jailed in mexico", 1, 1, 100.0, false]]
          end
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
