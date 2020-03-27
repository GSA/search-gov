require 'spec_helper'

describe RtuQueriesRequest do
  fixtures :affiliates

  before do
    allow(RtuDateRange).to receive(:new).and_return double(
      RtuDateRange, available_dates_range: ("2016-10-15".to_date.."2016-10-28".to_date),
      default_start: "2016-10-01".to_date,
      default_end: "2016-10-28".to_date
    )
  end

  let(:site) { affiliates(:basic_affiliate) }

  describe "#save" do
    describe "computing top query stats" do
      let(:rtu_queries_request) { RtuQueriesRequest.new("start_date" => "05/28/2014",
                                                        "end_date" => "05/28/2014",
                                                        "query" => "mexico petition marine",
                                                        "site" => site) }

      before do
        allow(TopQueryMatchQuery).to receive(:new).with(
          site.name,
          'mexico petition marine',
          Date.parse('05/28/2014'),
          Date.parse('05/28/2014'),
          field: 'params.query.raw',
          size: 1000
        ).and_return(instance_double(TopQueryMatchQuery, body: 'query_body'))
      end

      context "when stats available" do
        let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/rtu_queries_request.json")) }
        before do
          opts = { index: 'logstash-*',
                   body: 'query_body',
                   size: 0 }
          expect(ES::ELK.client_reader).to receive(:search).with(opts).and_return json_response
        end

        it 'should return an array of QueryClickCount objects sorted by desc query count' do
          rtu_queries_request.save
          arr = rtu_queries_request.top_queries.map { |qcc| [qcc.query, qcc.queries, qcc.clicks, qcc.ctr, qcc.is_routed_query] }
          expect(arr).to eq([["petition for marine held in mexico", 7, 2, 28.0, false],
                         ["petition for us marine jailed in mexico", 4, 0, 0.0, false],
                         ["marine in mexico petition", 2, 3, 150.0, false],
                         ["petition for marine jailed in mexico", 1, 1, 100.0, false]])
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
            expect(arr).to eq([["petition for marine held in mexico", 7, 2, 28.0, false],
                           ["petition for us marine jailed in mexico", 4, 0, 0.0, false],
                           ["marine in mexico petition", 2, 3, 150.0, true],
                           ["petition for marine jailed in mexico", 1, 1, 100.0, false]])
          end
        end

      end

      context 'when stats unavailable' do
        before do
          allow(ES::ELK.client_reader).to receive(:search).and_raise StandardError
          rtu_queries_request.save
        end

        it 'should return nil' do
          expect(rtu_queries_request.top_queries).to be_nil
        end
      end
    end

    describe "start and end dates" do
      before do
        allow(ES::ELK.client_reader).to receive(:search).and_raise StandardError
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
          expect(rtu_queries_request.start_date).to eq(Date.parse("05/27/2014"))
          expect(rtu_queries_request.end_date).to eq(Date.parse("05/28/2014"))
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
          expect(rtu_queries_request.end_date).to eq("2016-10-28".to_date)
        end
      end

      context "when neither is specified" do
        let(:rtu_queries_request) { RtuQueriesRequest.new("query" => "mexico petition marine", "site" => site) }

        before do
          allow_any_instance_of(RtuDateRange).to receive(:available_dates_range).
            and_return("2016-10-15".to_date.."2016-10-28".to_date)
          rtu_queries_request.save
        end

        it 'should use beginning of month of available dates range' do
          expect(rtu_queries_request.start_date).to eq("2016-10-01".to_date)
        end
      end
    end
  end
end
