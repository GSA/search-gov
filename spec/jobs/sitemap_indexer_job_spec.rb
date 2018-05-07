#require 'rails_helper'
require 'spec_helper'

RSpec.describe SitemapIndexerJob, type: :job do
  subject(:run_job) { SitemapIndexerJob.perform(args) }
  let(:job_args) { { domain: 'agency.gov', delay: 5 } }

  it 'works' do
    expect(SitemapIndexer).to receive(:new).with(domain: 'agency.gov', delay: 5)
    SitemapIndexerJob.perform_now(domain: 'agency.gov', delay: 5)
  end
end
