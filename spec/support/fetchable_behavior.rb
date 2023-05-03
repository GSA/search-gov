# frozen_string_literal: true

shared_examples_for 'a record with a fetchable url' do
  describe 'schema' do
    it { is_expected.to have_db_column(:url).of_type(:string).with_options(limit: 2000) }
    it { is_expected.to have_db_column(:last_crawl_status).of_type(:string) }
    it { is_expected.to have_db_column(:last_crawled_at).of_type(:datetime) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:url) }
    it { is_expected.to allow_value('https://some.site.gov/url').for(:url) }

    it 'limits the url length to 2000 characters' do
      record = described_class.new(valid_attributes.merge(url: ('x' * 2001)))
      expect(record).not_to be_valid
      expect(record.errors[:url]).to include('is too long (maximum is 2000 characters)')
    end

    context 'when last_crawl_status is > 255 characters' do
      let(:record) do
        described_class.new(valid_attributes.merge(last_crawl_status: 'x' * 300))
      end

      it 'is valid' do
        expect(record).to be_valid
      end

      it 'truncates the last_crawl_status to 255 characters' do
        expect { record.valid? }.to change { record.last_crawl_status.length }.
          from(300).to(255)
      end
    end
  end

  describe 'scopes' do
    context 'by last_crawl_status or last_crawled_at' do
      before do
        described_class.create!(valid_attributes.merge(url: 'https://agency.gov/ok',
                                                       last_crawl_status: 'OK',
                                                       last_crawled_at: 1.day.ago))
        described_class.create!(valid_attributes.merge(url: 'https://agency.gov/failed',
                                                       last_crawl_status: 'failed',
                                                       last_crawled_at: 1.day.ago))
        described_class.create!(valid_attributes.merge(url: 'https://agency.gov/unfetched',
                                                       last_crawl_status: nil,
                                                       last_crawled_at: nil))
      end

      describe '.fetched' do
        it 'includes successfully and unsuccessfully fetched records' do
          expect(described_class.fetched.pluck(:url)).
            to include('https://agency.gov/ok', 'https://agency.gov/failed')
        end

        it 'does not include unfetched records' do
          expect(described_class.fetched.pluck(:url)).
            not_to include 'https://agency.gov/unfetched'
        end
      end

      describe '.unfetched' do
        it 'includes unfetched records' do
          expect(described_class.unfetched.pluck(:url)).
            to include 'https://agency.gov/unfetched'
        end

        it 'does not include fetched records' do
          expect(described_class.unfetched.pluck(:url)).
            not_to include 'https://agency.gov/ok'
        end
      end

      describe '.ok' do
        it 'includes successfully fetched records' do
          expect(described_class.ok.pluck(:url)).
            to include 'https://agency.gov/ok'
        end
      end

      describe '.not_ok' do
        it 'includes failed or unfetched records' do
          expect(described_class.not_ok.pluck(:url)).
            to include('https://agency.gov/unfetched', 'https://agency.gov/failed')
        end
      end
    end
  end

  describe 'normalizing URLs when saving' do
    let(:record) { described_class.new(valid_attributes.merge(url: url)) }

    context 'when a blank URL is passed in' do
      let(:url) { '' }

      it 'marks record as invalid' do
        expect(described_class.new(valid_attributes.merge(url: url))).not_to be_valid
      end
    end

    context 'when an URL contains an anchor tag' do
      let(:url) { 'https://agency.gov/sdfsdf#anchorme' }

      it 'removes it' do
        expect(described_class.create!(valid_attributes.merge(url: url)).url).
          to eq('https://agency.gov/sdfsdf')
      end
    end

    context 'when URL is mixed case' do
      let(:url) { 'HTTPS://Agency.GOV/UsaGovLovesToCapitalize' }

      it 'should downcase the scheme and host only' do
        expect(described_class.create!(valid_attributes.merge(url: url)).url).
          to eq('https://agency.gov/UsaGovLovesToCapitalize')
      end
    end

    context 'when URL is missing trailing slash for a scheme+host URL' do
      let(:url) { 'https://agency.gov' }

      it 'appends a /' do
        expect(described_class.create!(valid_attributes.merge(url: url)).url).
          to eq('https://agency.gov/')
      end
    end

    context 'when URL contains duplicate leading slashes in request' do
      let(:url) { 'https://agency.gov//hey/I/am/usagov/and/love/extra////slashes.shtml' }

      it 'collapses the slashes' do
        expect(described_class.create!(valid_attributes.merge(url: url)).url).
          to eq('https://agency.gov/hey/I/am/usagov/and/love/extra/slashes.shtml')
      end
    end

    context "when URL doesn't have a protocol" do
      let(:url) { 'www.nps.gov/sdfsdf' }

      it 'prepends it with https://' do
        expect { record.valid? }.to change { record.url }.
          from(url).to('https://www.nps.gov/sdfsdf')
      end
    end

    context 'when the url contains query parameters' do
      let(:url) { 'https://www.irs.gov/foo?bar=baz' }

      it 'retains the query parameters' do
        expect { record.valid? }.not_to change { record.url }
      end
    end

    context 'when the url requires escaping' do
      let(:url) { 'https://www.foo.gov/my_url’s_weird!' }

      it 'escapes the url' do
        expect { record.valid? }.
          to change { record.url }.
          from(url).to('https://www.foo.gov/my_url%E2%80%99s_weird!')
      end

      context 'when the url is already escaped' do
        let(:url) { 'https://www.foo.gov/my_url%E2%80%99s_weird!' }

        it 'does not re-escape the url' do
          expect { record.valid? }.not_to(change { record.url })
        end
      end
    end
  end

  describe '#fetched?' do
    subject(:fetched) { record.fetched? }

    context 'when the record is new' do
      let(:record) { described_class.new(valid_attributes) }

      it { is_expected.to be false }
    end

    context 'when the record has been fetched' do
      let(:record) do
        described_class.new(valid_attributes.merge(last_crawled_at: 1.week.ago))
      end

      it { is_expected.to be true }
    end
  end

  describe '#indexed?' do
    subject(:indexed) { record.indexed? }

    context 'when the last_crawl_status = "OK"' do
      let(:record) do
        described_class.new(valid_attributes.merge(last_crawl_status: 'OK'))
      end

      it { is_expected.to be true }
    end

    context 'when the last_crawl_status != "OK"' do
      let(:record) do
        described_class.new(valid_attributes.merge(last_crawl_status: 'Womp womp'))
      end

      it { is_expected.to be false }
    end
  end
end

shared_examples_for 'a record with an indexable url' do
  describe 'validations' do
    context 'when the url extension is blacklisted' do
      let(:movie_url) { 'https://agency.gov/some.mov' }
      let(:record) { described_class.new(valid_attributes.merge(url: movie_url)) }

      it 'is not valid' do
        expect(record).not_to be_valid
        expect(record.errors.full_messages.first).to match(/extension is not one we index/i)
      end
    end
  end
end

shared_examples_for 'a record that requires https' do
  describe 'callbacks' do
    describe 'before_validation' do
      context 'when the URL uses http' do
        let(:record) do
          described_class.new(valid_attributes.merge(url: 'http://agency.gov/'))
        end

        it 'sets the scheme to https' do
          expect { record.valid? }.to change { record.url }.
            from('http://agency.gov/').to('https://agency.gov/')
        end
      end
    end
  end
end

shared_examples_for 'a record that belongs to a searchgov_domain' do
  describe 'associations' do
    it { is_expected.to belong_to(:searchgov_domain) }

    context 'on creation' do
      context 'when the domain already exists' do
        let!(:existing_domain) { SearchgovDomain.create!(domain: 'existing.gov') }
        let!(:sitemap) { described_class.create!(url: 'https://existing.gov/foo') }

        it 'sets the searchgov domain' do
          expect(sitemap.searchgov_domain).to eq(existing_domain)
        end
      end
    end
  end

  describe 'validations' do
    context "when the url's domain is invalid" do
      let(:invalid_url) { 'https://foo/bar' }

      it 'is not invalid' do
        expect(described_class.new(url: invalid_url)).not_to be_valid
      end
    end
  end
end
