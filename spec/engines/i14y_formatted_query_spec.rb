require 'spec_helper'

describe I14yFormattedQuery do
  describe '#query' do
    let(:query) { 'rutabaga' }
    let(:included_domains) { %w(included1.gov included2.gov) }
    let(:excluded_domains) { %w(excluded1.gov excluded2.gov) }
    subject { I14yFormattedQuery.new(query, options).query }

    context 'when included domains are present' do
      let(:options) { { included_domains: included_domains } }

      it { is_expected.to eq 'rutabaga site:included2.gov site:included1.gov' }
      context 'when searcher specifies sitelimit: within included domains' do
        subject {
          I14yFormattedQuery.new(
            'government',
            included_domains: included_domains,
            site_limits: 'included1.gov/subdir1 included1.gov/subdir2 include3.gov'
          )
        }

        it 'should assign matching_site_limits to just the site limits
            that match included domains' do
          expect(subject.query).
            to eq('government site:included1.gov/subdir2 site:included1.gov/subdir1')
          expect(subject.matching_site_limits).
            to eq(%w[included1.gov/subdir1 included1.gov/subdir2])
        end
      end

      context 'when searcher specifies sitelimit: outside included domains' do
        subject {
          I14yFormattedQuery.new(
            'government',
            included_domains: included_domains,
            site_limits: 'doesnotexist.gov'
          )
        }

        it 'should query the affiliates normal domains' do
          expect(subject.query).
            to eq('government site:included2.gov site:included1.gov')
          expect(subject.matching_site_limits).to be_empty
        end
      end
    end

    context 'when excluded domains are present' do
      let(:options) { { excluded_domains: excluded_domains } }

      it { is_expected.to eq 'rutabaga -site:excluded2.gov -site:excluded1.gov' }

      context 'when the query also contains excluded domains' do
        let(:query) { 'rutabaga -site:user_excluded.gov' }

        it { is_expected.to eq 'rutabaga -site:user_excluded.gov -site:excluded2.gov -site:excluded1.gov' }
      end
    end

    context 'when both included and excluded domains are present' do
      let(:options) do
        { included_domains: included_domains, excluded_domains: excluded_domains }
      end

      it { is_expected.to eq 'rutabaga -site:excluded2.gov -site:excluded1.gov site:included2.gov site:included1.gov' }
    end
  end
end