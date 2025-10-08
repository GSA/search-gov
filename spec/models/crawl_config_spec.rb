require 'spec_helper'

RSpec.describe CrawlConfig, type: :model do
  subject(:crawl_config) do
    described_class.new(
      name: 'Test SEO Crawler',
      allowed_domains: ['example.com'],
      starting_urls: ['https://example.com/start'],
      schedule: '30 08 * * MON',
      output_target: :search_engine
    )
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(crawl_config).to be_valid
    end

    it { is_expected.to validate_presence_of(:name) }
    it { is_expected.to validate_presence_of(:allowed_domains) }
    it { is_expected.to validate_presence_of(:starting_urls) }
    it { is_expected.to validate_presence_of(:schedule) }
    it { is_expected.to validate_presence_of(:output_target) }
    it { is_expected.to validate_numericality_of(:depth_limit).only_integer }
    it { is_expected.to define_enum_for(:output_target).with_values(endpoint: 'endpoint', search_engine: 'searchengine').backed_by_column_of_type(:string).with_prefix(:target) }

    context 'when a record exists' do
      before { crawl_config.save! }

      it 'validates uniqueness of allowed_domains scoped to output_target' do
        duplicate_config = described_class.new(
          name: 'Another Crawler',
          allowed_domains: crawl_config.allowed_domains,
          starting_urls: ['https://example.com/another'],
          schedule: '0 1 * * *',
          output_target: crawl_config.output_target
        )
        expect(duplicate_config).not_to be_valid
        expect(duplicate_config.errors[:allowed_domains]).to include('and output target combination must be unique')
      end

      it 'allows the same allowed_domains with a different output_target' do
        other_config = described_class.new(
          name: 'Another Crawler',
          allowed_domains: crawl_config.allowed_domains,
          starting_urls: ['https://example.com/another'],
          schedule: '0 1 * * *',
          output_target: :endpoint # Different from the subject's :search_engine
        )
        expect(other_config).to be_valid
      end
    end

    describe 'custom validation for schedule format' do
      it 'is invalid if the schedule is not a valid cron expression' do
        crawl_config.schedule = 'invalid-cron-string'
        expect(crawl_config).not_to be_valid
        expect(crawl_config.errors[:schedule]).to include(/is not a valid cron expression/)
      end
    end

    describe 'custom validation for starting URLs' do
      it 'is invalid if a starting URL is malformed' do
        crawl_config.starting_urls = ['not-a-valid-url']
        expect(crawl_config).not_to be_valid
        expect(crawl_config.errors[:starting_urls].join).to match(/contains an invalid URL/)
      end

      it 'is invalid if a starting URL is not HTTP or HTTPS' do
        crawl_config.starting_urls = ['ftp://example.com']
        expect(crawl_config).not_to be_valid
        expect(crawl_config.errors[:starting_urls]).to include(/must be HTTP or HTTPS/)
      end

      it 'is invalid if a starting URL does not belong to an allowed domain' do
        crawl_config.allowed_domains = ['example.com']
        crawl_config.starting_urls = ['https://another-domain.com']
        expect(crawl_config).not_to be_valid
        expect(crawl_config.errors[:starting_urls]).to include(/does not belong to any of the allowed domains/)
      end

      it 'is valid if a starting URL is a subdomain of an allowed domain' do
        crawl_config.allowed_domains = ['example.com']
        crawl_config.starting_urls = ['https://sub.example.com']
        expect(crawl_config).to be_valid
      end
    end
  end

  describe 'callbacks' do
    it 'sorts and uniquifies allowed_domains' do
      crawl_config.allowed_domains = ['c.com', 'a.com', 'b.com', 'a.com']
      crawl_config.valid?
      expect(crawl_config.allowed_domains).to eq(['a.com', 'b.com', 'c.com'])
    end

    it 'sorts and uniquifies starting_urls' do
      crawl_config.allowed_domains = ['a.com', 'b.com', 'c.com']
      crawl_config.starting_urls = ['https://c.com', 'https://a.com', 'https://b.com', 'https://a.com']
      crawl_config.valid?
      expect(crawl_config.starting_urls).to eq(['https://a.com', 'https://b.com', 'https://c.com'])
    end
  end

  describe 'defaults' do
    let(:new_config) { described_class.new }

    it 'defaults active to true' do
      expect(new_config.active).to be true
    end

    it 'defaults depth_limit to 3' do
      expect(new_config.depth_limit).to eq(3)
    end

    it 'defaults allow_query_string to false' do
      expect(new_config.allow_query_string).to be false
    end

    it 'defaults handle_javascript to false' do
      expect(new_config.handle_javascript).to be false
    end
  end

  describe 'serialization' do
    it 'correctly saves and retrieves array fields' do
      config = described_class.create!(
        name: 'Serialization Test',
        allowed_domains: ['domain1.com', 'domain2.com'],
        starting_urls: ['https://domain1.com', 'https://domain2.com'],
        sitemap_urls: ['https://domain1.com/sitemap.xml'],
        deny_paths: ['/private', '/admin'],
        schedule: '* * * * *',
        output_target: 'endpoint'
      )
      config.reload

      expect(config.allowed_domains).to match_array(['domain1.com', 'domain2.com'])
      expect(config.starting_urls).to match_array(['https://domain1.com', 'https://domain2.com'])
      expect(config.sitemap_urls).to match_array(['https://domain1.com/sitemap.xml'])
      expect(config.deny_paths).to match_array(['/private', '/admin'])
    end

    it 'handles nil and empty arrays gracefully' do
      config = described_class.create!(
        name: 'Empty Array Test',
        allowed_domains: ['test.com'],
        starting_urls: ['https://test.com'],
        sitemap_urls: nil,
        deny_paths: [],
        schedule: '* * * * *',
        output_target: 'endpoint'
      )
      config.reload

      expect(config.sitemap_urls).to eq([])
      expect(config.deny_paths).to eq([])
    end
  end
end
