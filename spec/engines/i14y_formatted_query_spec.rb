require 'spec_helper'

describe I14yFormattedQuery do
  describe '#query' do
    let(:query) { 'rutabaga' }
    let(:included_domains) { %w(included1.gov included2.gov) }
    let(:excluded_domains) { %w(excluded1.gov excluded2.gov) }
    subject { I14yFormattedQuery.new(query, options).query }

    context 'when included domains are present' do
      let(:options) { { included_domains: included_domains } }

      it { should eq 'rutabaga site:included2.gov site:included1.gov' }
    end

    context 'when excluded domains are present' do
      let(:options) { { excluded_domains: excluded_domains } }

      it { should eq 'rutabaga -site:excluded2.gov -site:excluded1.gov' }

      context 'when the query also contains excluded domains' do
        let(:query) { 'rutabaga -site:user_excluded.gov' }

        it { should eq 'rutabaga -site:user_excluded.gov -site:excluded2.gov -site:excluded1.gov' }
      end
    end

    context 'when both included and excluded domains are present' do
      let(:options) do
        { included_domains: included_domains, excluded_domains: excluded_domains }
      end

      it { should eq 'rutabaga -site:excluded2.gov -site:excluded1.gov site:included2.gov site:included1.gov' }
    end
  end
end