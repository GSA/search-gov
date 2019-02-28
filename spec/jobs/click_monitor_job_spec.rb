require 'spec_helper'

describe ClickMonitorJob do
  subject(:perform) { ClickMonitorJob.perform_now }

  let(:searchgov_domain) do
    instance_double(SearchgovDomain, domain: 'agency.gov')
  end

  before do
    allow(SearchgovDomain).to receive(:find_each).and_yield(searchgov_domain)
  end

  it_behaves_like 'a searchgov job'

  it 'enqueues ClickCounterJobs for each SearchgovDomain' do
    expect{ perform }.to have_enqueued_job(ClickCounterJob).
      with(domain: 'agency.gov')
  end
end
