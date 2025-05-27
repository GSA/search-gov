require 'spec_helper'

describe ClickMonitorSpiderJob do
  subject(:job) { described_class.new }

  let(:searchgov_domain) do
    instance_double(SearchgovDomain, domain: 'nasa.gov')
  end

  before do
    allow(SearchgovDomain).to receive(:find_each).and_yield(searchgov_domain)
  end

  it_behaves_like 'a searchgov job'

  it 'enqueues ClickCounterJobs for each SearchgovDomain' do
    expect { job.perform_now }.to have_enqueued_job(ClickCounterJob)
      .with(domain: searchgov_domain.domain, index_name: ENV.fetch('SEARCHELASTIC_INDEX'))
  end
end
