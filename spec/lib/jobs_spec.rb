require 'spec_helper'

describe Jobs do
  describe '.search(options)' do
    subject(:search) do
      Jobs.search({ query:'jobs',
                    organization_code: '',
                    location_name: 'Washington, DC, United States',
                    results_per_page: 10,
                  })
    end

    it 'returns results' do
      expect(search.search_result.search_result_count).to eq 10
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

    context "when the search is within radius but different city" do
      before do
        Jobs.search({ query:'jobs',
          organization_code: 'HE38',
          location_name: 'Baltimore, MD, United States',
          results_per_page: 10,
        })
      end

      it "should return results" do
        expect(search.search_result.search_result_count).to be > 0
      end
    end
  end

  describe 'job_scrub(query)' do
    context 'when the search phrase contains the a job related keyword' do
      it 'should return the query with out the job related keyword at the end of the query' do
        expect(Jobs.job_scrub('Nursing jobs')).to eq('Nursing')
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
