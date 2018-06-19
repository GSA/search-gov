require 'spec_helper'

describe Sitemap do

  it { is_expected.to have_readonly_attribute(:url) }

  describe 'schema' do
    it { is_expected.to have_db_column(:url).of_type(:string).with_options(null: false, limit: 255) }
    it { is_expected.to have_db_column(:last_crawl_status).of_type(:string) }
    it { is_expected.to have_db_column(:last_crawled_at).of_type(:datetime) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:searchgov_domain) }

    context 'on creation' do
      context 'when the domain already exists' do
        let!(:existing_domain) { SearchgovDomain.create!(domain: 'existing.gov') }

        it 'sets the searchgov domain' do
          sitemap = Sitemap.create!(url: 'https://existing.gov/foo')
          expect(sitemap.searchgov_domain).to eq(existing_domain)
        end
      end
    end
  end

  # it_should_behave_like 'a record with a fetchable url'
end