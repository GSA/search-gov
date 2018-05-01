require 'spec_helper'

describe SearchgovDomain do
  let(:domain) { 'agency.gov' }
  subject(:searchgov_domain) { SearchgovDomain.new(domain: domain) }

  it { is_expected.to have_readonly_attribute(:domain) }

  describe 'schema' do
    it do
      is_expected.to have_db_column(:domain).of_type(:string).
        with_options(null: false)
    end

    it do
      is_expected.to have_db_column(:clean_urls).of_type(:boolean).
        with_options(default: true, null: false)
    end

    it do
      is_expected.to have_db_column(:status).of_type(:string).
        with_options(null: true)
    end

    it do
      is_expected.to have_db_column(:urls_count).of_type(:integer).
        with_options(null: false, default: 0)
    end

    it do
      is_expected.to have_db_column(:unfetched_urls_count).of_type(:integer).
        with_options(null: false, default: 0)
    end

    it { is_expected.to have_db_index(:domain).unique(true) }
  end

  describe 'associations' do
    it { is_expected.to have_many(:searchgov_urls).dependent(:destroy) }
  end

  describe 'validations' do
    it 'validates the domain format' do
      expect(SearchgovDomain.new(domain: 'foo')).not_to be_valid
      expect(SearchgovDomain.new(domain: 'search.gov')).to be_valid
    end
  end

  describe 'counter columns' do
    let(:searchgov_domain) { SearchgovDomain.create(domain: domain) }

    describe '#urls_count' do
      it 'tracks the number of associated searchgov url records' do
        expect{
          searchgov_domain.searchgov_urls.create!(url: 'https://agency.gov')
        }.to change{ searchgov_domain.reload.urls_count }.by(1)
      end
    end

    describe '#unfetched_urls_count' do
      it 'tracks the number of unfetched searchgov url records' do
        searchgov_domain.searchgov_urls.create!(url: 'https://agency.gov/fetched', last_crawled_at: 1.day.ago)
        searchgov_domain.searchgov_urls.create!(url: 'https://agency.gov/unfetched')
        expect(searchgov_domain.reload.unfetched_urls_count).to eq 1
      end
    end
  end
end
