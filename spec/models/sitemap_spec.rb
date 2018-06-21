require 'spec_helper'

describe Sitemap do
  let!(:url) { 'http://www.agency.gov/boring' }
  let!(:html) { read_fixture_file("/html/page_with_og_metadata.html") }
  let!(:valid_attributes) { { url: url } }
  let!(:sitemap) { Sitemap.new(valid_attributes) }
  let!(:existing_domain) { SearchgovDomain.create!(domain: 'existing.gov') }
  # x = Sitemap.find_by(url: 'http://www.agency.gov/borin')
  # x.destroy

  it { is_expected.to have_readonly_attribute(:url) }

  describe 'schema' do
    it { is_expected.to have_db_column(:url).of_type(:string).with_options(null: false, limit: 2000) } # causing problems for I'm not sure why
    it { is_expected.to have_db_column(:last_crawl_status).of_type(:string) }
    it { is_expected.to have_db_column(:last_crawled_at).of_type(:datetime) }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:searchgov_domain) }

    context 'on creation' do
      context 'when the domain already exists' do
        it 'sets the searchgov domain' do
          sitemap = Sitemap.create!(url: 'https://existing.gov/foo.xml')
          expect(sitemap.searchgov_domain).to eq(existing_domain)
        end
      end

      context 'when the domain has not been created yet' do
        it 'creates the domain' do
          expect{ Sitemap.create!(url: 'https://brandnewdomain.gov/loop.txt') }.
            to change{ SearchgovDomain.count }.by(1)
        end
      end
    end
  end

  describe 'validations' do
    it 'requires a valid domain' do
      sitemap = Sitemap.new(url: 'https://foo/bar')
      expect(sitemap).not_to be_valid
    end

    context 'when validating url uniqueness' do
      let!(:existing) { Sitemap.create!(valid_attributes) }

      it { is_expected.to validate_uniqueness_of(:url).on(:create) }

      it 'is case-sensitive' do
        expect(Sitemap.new(url: 'https://www.agency.gov/BORING.xml')).to be_valid
      end
    end

    context 'when validating url presence (not being nil)' do
      let!(:attempt) { Sitemap.new }

      it { is_expected.not_to be_valid }
    end

    context 'when validating last_crawl_status when it is > 255 characters' do
      it 'should accept the status and truncate it' do
        error_status = (0..300).collect {|x| x.to_s}
        temp = Sitemap.new(url: 'http://www.agency.gov/boring', last_crawl_status: error_status)

        expect(temp).to be_valid
        expect(temp.last_crawl_status.length).to eq(255)
      end
    end
  end

  it_should_behave_like 'a record with a fetchable url'
end