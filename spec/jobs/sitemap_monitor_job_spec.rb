# frozen_string_literal: true

require 'spec_helper'

describe SitemapMonitorJob do
  subject(:perform) { described_class.perform_now }

  let(:searchgov_domain) { instance_double(SearchgovDomain) }

  it_behaves_like 'a sitemap job'

  context 'when a domain had failed previously' do
    before do
      allow(SearchgovDomain).to receive_message_chain(:not_ok, :find_each).
        and_yield(searchgov_domain)
    end

    it 're-checks failed domains' do
      expect(searchgov_domain).to receive(:check_status)
      perform
    end
  end

  context 'when domains can be indexed' do
    before do
      allow(SearchgovDomain).to receive_message_chain(:ok, :find_each).
        and_yield(searchgov_domain)
    end

    it 'indexes sitemaps' do
      expect(searchgov_domain).to receive(:index_sitemaps)
      perform
    end
  end
end
