# frozen_string_literal: true

require 'spec_helper'

describe SitemapMonitorJob do
  subject(:perform) { described_class.perform_now }

  before do 
    SearchgovDomain.all.map(&:delete)
  end

  let(:searchgov_domain) { SearchgovDomain.find_or_create_by!(domain: 'agency.gov', status: '200 OK') }
  # let(:searchgov_domain2) { SearchgovDomain.find_or_create_by!(domain: 'searchgov.gov') }
  # subject(:check_status) { searchgov_domain2.check_status }

  it_behaves_like 'a sitemap job'

  context 'when domains can be indexed' do
    it 'indexes sitemaps' do
      searchgov_domain
      expect { perform }.to have_enqueued_job(SitemapIndexerJob)
    end
  end

  # context 'when a domain had failed previously' do
  #   it 're-checks failed domains' do
  #     expect(searchgov_domain2).to receive(check_status)
  #     perform
  #   end
  # end
end
