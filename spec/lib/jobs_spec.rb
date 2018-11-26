require 'spec_helper'

describe Jobs do
  describe '.search(options)' do
    subject(:search) do
      Jobs.search({ query:'jobs',
                    organization_code: '',
                    location_name: '',
                    results_per_page: 10})
    end
    let(:usajobs_url) {'https://data.usajobs.gov/api/search'}
    it 'returns results' do
      expect(search.search_result.search_result_count).to eq 10
    end

    it 'searches USAJOBS with the correct params' do
      search
      expect(a_request(:get, usajobs_url).with(
        query: {
          Keyword:        '',
          Organization:   '',
          LocationName:   "Washington, DC, USA",
          ResultsPerPage: 10},
        headers: {
          'Accept': '*/*',
          'Accept-Encoding': 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
          'Connection': 'keep-alive',
          'Keep-Alive': '30',
       }
      )).to have_been_made
    end

    context "when there is some problem" do
      before do
        stub_request(:get, %r{data.usajobs.gov}).to_raise(StandardError)
      end

      it "should log any errors that occur and return nil" do
        expect(Rails.logger).to receive(:error).
          with(/Trouble fetching jobs information/)
        expect(search).to be_nil
      end
    end
  end

  describe '.scrub_keyword(query)' do
    context 'when the search phrase contains a job related keyword' do
      it 'should return the query with out the job related keyword at the end of the query' do
        expect(Jobs.scrub_keyword('Nursing jobs')).to eq('Nursing')
      end

      it 'should return blank if its equal to one of these job term keywords job,employment,posting,position' do
        expect(Jobs.scrub_keyword('jobs')).to eq('')
      end

      it 'should return job related keyword if its the same as query and not equal to job term keywords.' do
        expect(Jobs.scrub_keyword('internship')).to eq('internship')
      end

    end
  end
  
  describe '.query_eligible?(query)' do
    context 'when the search phrase contains hyphenated words' do
      it 'should return true' do
        expect(Jobs.query_eligible?('full-time jobs')).to be true
        expect(Jobs.query_eligible?('intern')).to be true
        expect(Jobs.query_eligible?('seasonal')).to be true
      end
    end

    context 'when the search phrase is blocked' do
      it 'should return false' do
        ["employment data", "employment statistics", "employment numbers", "employment levels", "employment rate",
         "employment trends", "employment growth", "employment projections", "employment #{Date.current.year.to_s}",
         "employment survey", "employment forecasts", "employment figures", "employment report", "employment law",
         "employment at will", "equal employment opportunity", "employment verification", "employment status",
         "employment record", "employment history", "employment eligibility", "employment authorization", "employment card",
         "job classification", "job analysis", "posting 300 log", "employment forms", "job hazard", "job safety",
         "job poster", "job training", "employment training", "job fair", "job board", "job outlook", "grant opportunities",
         "funding opportunities", "vacancy factor", "vacancy rates", "delayed opening", "opening others mail", "job corps cuts",
         "job application", "job safety and health poster", "job safety analysis standard", "job safety analysis", "employment contract",
         "application for employment"
        ].each { |phrase| expect(Jobs.query_eligible?(phrase)).to be false }
      end
    end

    context 'when the search phrase has advanced query characteristics' do
      it 'should return false' do
        ['job "city of farmington"',
         'job -loren',
         'job (assistant OR parks)',
         'job filetype:pdf',
         '-loren job'
        ].each { |phrase| expect(Jobs.query_eligible?(phrase)).to be false }
      end
    end
  end
end
