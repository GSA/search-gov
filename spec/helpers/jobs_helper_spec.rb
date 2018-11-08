require 'spec_helper'

describe JobsHelper do
  fixtures :affiliates

  describe '#format_salary' do
    it 'should return nil when minimum is nil' do
      job = double('job', minimum: nil, maximum: nil, rate_interval_code: 'PA')
      expect(helper.format_salary(job)).to be_nil
    end

    it 'should return nil when minimum is zero and maximum is nil' do
      job = double('job', minimum: 0, maximum: nil, rate_interval_code: 'PH')
      expect(helper.format_salary(job)).to be_nil
    end

    it 'should return salary when minimum is not zero and maximum is nil' do
      job = double('job', minimum: 17.50, maximum: nil, rate_interval_code: 'PH')
      expect(helper.format_salary(job)).to eq('$17.50/hr')
    end

    it 'should return salary when the rate interval is not PA, PH or WC' do
      job = double('job', minimum: 17.50, maximum: nil, rate_interval_code: 'PD')
      expect(helper.format_salary(job)).to eq('$17.50 Per Day')
    end

    it 'should return salary range when maximum is not nil and the rate interval is not PA, PH or WC' do
      job = double('job', minimum: 17.50, maximum: 20.50, rate_interval_code: 'PD')
      expect(helper.format_salary(job)).to eq('$17.50-$20.50 Per Day')
    end
  end

  describe '#job_application_deadline' do
    it 'should return nil when end date is nil' do
      expect(helper.job_application_deadline(nil)).to be_nil
    end
  end

  describe '#legacy_link_to_more_jobs' do
    context 'when rendering federal jobs' do
      it 'should render a link to usajobs.gov' do
        affiliate = mock_model(Affiliate, has_organization_codes?: false)
        search = double('search', affiliate: affiliate, query: 'gov')
        allow(search).to receive_message_chain(:affiliate, :agency).and_return(nil)
        expect(helper).to receive(:job_link_with_click_tracking).with(
            'More federal job openings on USAJobs.gov',
            'https://www.usajobs.gov/Search/Results?hp=public',
            search.affiliate, 'gov', -1, nil)
        helper.legacy_link_to_more_jobs(search)
      end
    end

    context 'when rendering federal jobs for a given organization' do
      let(:search) do
        affiliate = affiliates(:usagov_affiliate)
        agency = Agency.create!(abbreviation: 'GSA', name: 'blah')
        AgencyOrganizationCode.create!(organization_code: "GS", agency: agency)
        AgencyOrganizationCode.create!(organization_code: "HI", agency: agency)
        affiliate.agency = agency
        double('search', affiliate: affiliate, query: 'gov')
      end

      before do
        allow(search).to receive_message_chain(:jobs).and_return([double('job', id: 'usajobs:1000')])
      end

      it 'should render an organization specific link to usajobs.gov' do
        expect(helper).to receive(:job_link_with_click_tracking).with(
            'More GSA job openings on USAJobs.gov',
            'https://www.usajobs.gov/Search/Results?a=GS&a=HI',
            search.affiliate, 'gov', -1, nil)
        helper.legacy_link_to_more_jobs(search)
      end

      context 'when the affiliate locale is es' do
        before { I18n.locale = :es }
        after { I18n.locale = I18n.default_locale }

        it 'should render an organization specific link to usajobs in Spanish' do
          expect(helper).to receive(:job_link_with_click_tracking).with(
              'Más trabajos en GSA en USAJobs.gov',
              'https://www.usajobs.gov/Search/Results?a=GS&a=HI',
              search.affiliate, 'gov', -1, nil)
          helper.legacy_link_to_more_jobs(search)
        end
      end
    end

    context 'when rendering neogov jobs for a given organization' do
      let(:search) do
        affiliate = affiliates(:usagov_affiliate)
        agency = Agency.create!(name: 'State of Michigan')
        AgencyOrganizationCode.create!(organization_code: "USMI", agency: agency)
        affiliate.agency = agency
        double('search', affiliate: affiliate, query: 'gov')
      end

      before do
        allow(search).to receive_message_chain(:jobs).and_return([double('job', id: 'ng:michigan:1000')])
      end

      it 'should render an organization specific link to usajobs.gov' do
        expect(helper).to receive(:job_link_with_click_tracking).with(
            'More State of Michigan job openings',
            'http://agency.governmentjobs.com/michigan/default.cfm',
            search.affiliate, 'gov', -1, nil)
        helper.legacy_link_to_more_jobs(search)
      end

      context 'when the affiliate locale is es' do
        before { I18n.locale = :es }
        after { I18n.locale = I18n.default_locale }

        it 'should render an organization specific link to usajobs in Spanish' do
          expect(helper).to receive(:job_link_with_click_tracking).with(
              'Más trabajos en State of Michigan',
              'http://agency.governmentjobs.com/michigan/default.cfm',
              search.affiliate, 'gov', -1, nil)
          helper.legacy_link_to_more_jobs(search)
        end
      end
    end
  end
end
