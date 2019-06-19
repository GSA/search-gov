require 'spec_helper'

describe Jobs do
  describe '.search(options)' do
    subject(:search) do
      Jobs.search({ query:'Nursing jobs',
                    organization_codes: 'HE38',
                    location_name: 'Baltimore, MD, USA',
                    results_per_page: 10 })
    end
    let(:usajobs_url) { 'https://data.usajobs.gov/api/search' }
    it 'returns results' do
      expect(search.search_result.search_result_count).to be > 0
    end

    it 'searches USAJOBS with the correct params' do
      search
      expect(a_request(:get, usajobs_url).with(
        query: { Keyword:        'Nursing',
                 Organization:   'HE38',
                 LocationName:   'Baltimore, MD, USA',
                 ResultsPerPage: 10,
                 Radius:         75 }
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

  describe '.scrub_query(query)' do
    context 'when the search phrase contains a job related keyword' do
      it 'returns the query without generic job keywords' do
        expect(Jobs.scrub_query('Nursing jobs')).to eq('Nursing')
      end

      it 'returns blank when the query is a generic job keyword' do
        %w[ position opening posting job employment career trabajo
            carrera puesto empleo vacante opportunity vacancy posicion
            ocupacion oportunidad ].each do |query|
          expect(Jobs.scrub_query(query)).to eq('')
        end
      end

      it 'returns job related keyword if the query is the same, and not a generic job keyword.' do
        expect(Jobs.scrub_query('internship')).to eq('internship')
      end

      it 'returns blank when the query only contains generic job keywords.' do
        expect(Jobs.scrub_query('job posting')).to eq('')
      end

      it 'returns the job related keyword when the query is a job related keyword and generic job keyword' do
        expect(Jobs.scrub_query('internship job')).to eq('internship')
      end

      it 'does include the job related keyword if it is part of another word' do
        expect(Jobs.scrub_query('grand reopening')).to eq('grand reopening')
      end

      it 'is case sensitive when scrubbing queries' do
        expect(Jobs.scrub_query('JoB')).to eq('')
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

    context 'when the search phrase contains search key word inside the word' do
      it 'should return false' do
        expect(Jobs.query_eligible?('international store')).to be_falsey
      end
    end

    context 'when the search phrase does not include job-related keyword' do
      it 'does not trigger job search' do
        expect(Jobs.query_eligible?('federal')).to be_falsey
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
        ].each { |phrase| expect(Jobs.query_eligible?(phrase)).to be_falsey }
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
