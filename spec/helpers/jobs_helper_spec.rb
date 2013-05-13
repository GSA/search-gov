require 'spec_helper'

describe JobsHelper do
  describe '#format_salary' do
    it 'should return nil when minimum is nil' do
      job = mock('job', minimum: nil, maximum: nil, rate_interval_code: 'PA')
      helper.format_salary(job).should be_nil
    end

    it 'should return nil when minimum is zero and maximum is nil' do
      job = mock('job', minimum: 0, maximum: nil, rate_interval_code: 'PH')
      helper.format_salary(job).should be_nil
    end

    it 'should return salary when minimum is not zero and maximum is nil' do
      job = mock('job', minimum: 17.50, maximum: nil, rate_interval_code: 'PH')
      helper.format_salary(job).should == '$17.50/hr'
    end

    it 'should return salary when the rate interval is not PA, PH or WC' do
      job = mock('job', minimum: 17.50, maximum: nil, rate_interval_code: 'PD')
      helper.format_salary(job).should == '$17.50 Per Day'
    end

    it 'should return salary range when maximum is not nil and the rate interval is not PA, PH or WC' do
      job = mock('job', minimum: 17.50, maximum: 20.50, rate_interval_code: 'PD')
      helper.format_salary(job).should == '$17.50-$20.50 Per Day'
    end
  end

  describe '#job_application_deadline' do
    it 'should return nil when end date is nil' do
      helper.job_application_deadline(nil).should be_nil
    end
  end

  describe '#agency_jobs_link' do
    context 'when rendering federal jobs' do
      it 'should render a link to usajobs.gov' do
        search = mock('search', affiliate: mock_model(Affiliate), query: 'gov')
        search.stub_chain(:affiliate, :agency).and_return(nil)
        helper.should_receive(:job_link_with_click_tracking).with(
            'See all federal job openings',
            'https://www.usajobs.gov/JobSearch/Search/GetResults?PostingChannelID=USASearch',
            search.affiliate, 'gov', -1, nil)
        helper.agency_jobs_link(search)
      end
    end

    context 'when rendering federal jobs for a given organization' do
      let(:search) { mock('search', affiliate: mock_model(Affiliate), query: 'gov') }
      before do
        agency = mock_model(Agency, abbreviation: 'GSA', organization_code: 'GS')
        search.stub_chain(:affiliate, :agency).and_return(agency)
        search.stub_chain(:jobs).and_return([mock('job', id: 'usajobs:1000')])
      end

      it 'should render an organization specific link to usajobs.gov' do
        helper.should_receive(:job_link_with_click_tracking).with(
            'See all GSA job openings',
            'https://www.usajobs.gov/JobSearch/Search/GetResults?organizationid=GS&PostingChannelID=USASearch',
            search.affiliate, 'gov', -1, nil)
        helper.agency_jobs_link(search)
      end

      context 'when the affiliate locale is es' do
        before { I18n.locale = :es }
        after { I18n.locale = I18n.default_locale }

        it 'should render an organization specific link to usajobs in Spanish' do
          helper.should_receive(:job_link_with_click_tracking).with(
              'Vea todos los trabajos en GSA',
              'https://www.usajobs.gov/JobSearch/Search/GetResults?organizationid=GS&PostingChannelID=USASearch',
              search.affiliate, 'gov', -1, nil)
          helper.agency_jobs_link(search)
        end
      end
    end

    context 'when rendering neogov jobs for a given organization' do
      let(:search) { mock('search', affiliate: mock_model(Affiliate), query: 'gov') }

      before do
        agency = mock_model(Agency, name: 'State of Michigan', organization_code: 'USMI')
        search.stub_chain(:affiliate, :agency).and_return(agency)
        search.stub_chain(:jobs).and_return([mock('job', id: 'ng:michigan:1000')])
      end

      it 'should render an organization specific link to usajobs.gov' do
        helper.should_receive(:job_link_with_click_tracking).with(
            'See all State of Michigan job openings',
            'http://agency.governmentjobs.com/michigan/default.cfm',
            search.affiliate, 'gov', -1, nil)
        helper.agency_jobs_link(search)
      end

      context 'when the affiliate locale is es' do
        before { I18n.locale = :es }
        after { I18n.locale = I18n.default_locale }

        it 'should render an organization specific link to usajobs in Spanish' do
          helper.should_receive(:job_link_with_click_tracking).with(
              'Vea todos los trabajos en State of Michigan',
              'http://agency.governmentjobs.com/michigan/default.cfm',
              search.affiliate, 'gov', -1, nil)
          helper.agency_jobs_link(search)
        end
      end
    end
  end
end