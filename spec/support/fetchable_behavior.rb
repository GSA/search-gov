shared_examples_for 'a record with a fetchable url' do
  describe 'validations' do
    it { is_expected.to validate_presence_of :url }
    it { is_expected.to allow_value("http://some.site.gov/url").for(:url) }
    it { is_expected.to allow_value("http://some.site.mil/").for(:url) }
    it { is_expected.to allow_value("http://some.govsite.com/url").for(:url) }
    it { is_expected.to allow_value("http://some.govsite.us/url").for(:url) }
    it { is_expected.to allow_value("http://some.govsite.info/url").for(:url) }
    it { is_expected.to allow_value("https://some.govsite.info/url").for(:url) }

    it 'limits the url length to 2000 characters' do
      record = described_class.new(valid_attributes.merge(url: ('x' * 2001) ))
      expect(record).not_to be_valid
      expect(record.errors[:url]).to include("is too long (maximum is 2000 characters)")
    end

    context 'when the url extension is blacklisted' do
      let(:movie_url) { "http://www.nps.gov/some.mov" }
      let(:record) { described_class.new(valid_attributes.merge(url: movie_url)) }

      it "is not valid" do
        expect(record).not_to be_valid
        expect(record.errors.full_messages.first).to match(/extension is not one we index/i)
      end
    end
  end

  describe 'scopes' do
    context 'by last_crawl_status or last_crawled_at' do
      before do
        described_class.create!(valid_attributes.merge(url: 'http://agency.gov/ok', last_crawl_status: 'OK', last_crawled_at: 1.day.ago))
        described_class.create!(valid_attributes.merge(url: 'http://agency.gov/failed', last_crawl_status: 'failed', last_crawled_at: 1.day.ago))
        described_class.create!(valid_attributes.merge(url: 'http://agency.gov/unfetched', last_crawl_status: nil, last_crawled_at: nil))
      end

      describe '.fetched' do
        it 'includes successfully and unsuccessfully fetched records' do
          expect(described_class.fetched.pluck(:url)).
            to match_array %w[http://agency.gov/ok http://agency.gov/failed]
        end
      end

      describe '.unfetched' do
        it 'includes unfetched records' do
          expect(described_class.unfetched.pluck(:url)).to eq ['http://agency.gov/unfetched']
        end
      end

      describe '.ok' do
        it 'includes successfully fetched records' do
          expect(described_class.ok.pluck(:url)).to match_array ['http://agency.gov/ok']
        end
      end

      describe '.not_ok' do
        it 'includes failed or unfetched records' do
          expect(described_class.not_ok.pluck(:url)).
            to match_array %w[http://agency.gov/unfetched http://agency.gov/failed]
        end
      end
    end
  end

  describe "normalizing URLs when saving" do
    context "when a blank URL is passed in" do
      let(:url) { "" }
      it 'should mark record as invalid' do
        expect(described_class.new(valid_attributes.merge(url: url))).not_to be_valid
      end
    end

    context "when an URL contains an anchor tag" do
      let(:url) { "http://www.nps.gov/sdfsdf#anchorme" }
      it "should remove it" do
        expect(described_class.create!(valid_attributes.merge(url: url)).url).to eq("http://www.nps.gov/sdfsdf")
      end
    end

    context "when URL is mixed case" do
      let(:url) { "HTTP://Www.nps.GOV/UsaGovLovesToCapitalize" }
      it "should downcase the scheme and host only" do
        expect(described_class.create!(valid_attributes.merge(url: url)).url).to eq("http://www.nps.gov/UsaGovLovesToCapitalize")
      end
    end

    context "when URL is missing trailing slash for a scheme+host URL" do
      let(:url) { "http://www.nps.gov" }
      it "should append a /" do
        expect(described_class.create!(valid_attributes.merge(url: url)).url).to eq("http://www.nps.gov/")
      end
    end

    context "when URL contains duplicate leading slashes in request" do
      let(:url) { "http://www.nps.gov//hey/I/am/usagov/and/love/extra////slashes.shtml" }
      it "should collapse the slashes" do
        expect(described_class.create!(valid_attributes.merge(url: url)).url).to eq("http://www.nps.gov/hey/I/am/usagov/and/love/extra/slashes.shtml")
      end
    end
  end

  describe '#fetched?' do
    subject(:fetched) { record.fetched? }

    context 'when the record is new' do
      let(:record) { described_class.new(valid_attributes) }

      it { is_expected.to eq false }
    end

    context 'when the record has been fetched' do
      let(:record) do
        described_class.new(valid_attributes.merge(last_crawled_at: 1.week.ago))
      end

      it { is_expected.to eq true }
    end
  end

  describe '#indexed?' do
    subject(:indexed) { record.indexed? }

    context 'when the last_crawl_status = "OK"' do
      let(:record) do
        described_class.new(valid_attributes.merge(last_crawl_status: 'OK'))
      end

      it { is_expected.to eq true }
    end

    context 'when the last_crawl_status != "OK"' do
      let(:record) do
        described_class.new(valid_attributes.merge(last_crawl_status: 'Womp womp'))
      end

      it { is_expected.to eq false }
    end
  end
end
