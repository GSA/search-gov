require 'spec_helper'

describe SiteAutodiscoverer do
  let(:site) { mock_model(Affiliate) }
  let(:autodiscoverer) { described_class.new(site, autodiscovery_url) }
  let(:autodiscovery_url) { nil }

  describe '#initialize' do
    context 'when autodiscovery_url is not present' do
      it 'should initialize correctly' do
        expect(autodiscoverer).to be_a(described_class)
      end
    end

    context 'when autodiscovery_url is present and valid' do
      let(:autodiscovery_url) { 'https://www.usa.gov' }

      it 'should initialize correctly' do
        expect(autodiscoverer).to be_a(described_class)
      end
    end

    context 'when the autodiscovery_url is present but invalid' do
      let(:autodiscovery_url) { 'Four score and seven years ago' }

      it 'should raise an error' do
        expect { autodiscoverer }.to raise_error(URI::InvalidURIError)
      end
    end
  end

  describe '#autodiscovery_url' do
    subject { autodiscoverer.autodiscovery_url }

    context 'when no autodiscovery_url is provided to the constructor' do
      context 'when the site has no default_autodiscovery_url' do
        before do
          allow(site).to receive(:default_autodiscovery_url) { nil }
        end

        it 'has no autodiscovery_url' do
          expect(subject).to be_nil
        end
      end

      context 'when the site has a default_autodiscovery_url' do
        let(:url) { 'https://www.usa.gov' }

        before do
          allow(site).to receive(:default_autodiscovery_url) { url }
          allow(autodiscoverer).to receive(:autodiscover_website).with(url).and_return(url)
        end

        it "should verify the site's default_autodiscovery_url" do
          expect(subject).to eq(url)
        end

        context 'when the autodiscover_website returns a different url' do
          let(:other_url) { 'https://www.usa.gov' }

          before do
            allow(autodiscoverer).to receive(:autodiscover_website).with(url).and_return(other_url)
          end

          it "should use the site's alternative, autodiscovered url" do
            expect(subject).to eq(other_url)
          end
        end
      end
    end

    context 'when an autodiscovery_url is provided to the constructuro' do
      let(:autodiscovery_url) { 'https://www.usa.gov' }

      it 'should remember the provided autodiscovery_url' do
        expect(subject).to eq(autodiscovery_url)
      end
    end
  end

  describe '#autodiscover_website' do
    subject { described_class.new(site).autodiscover_website(base_url) }

    context 'when base_url is nil' do
      let(:base_url) { nil }

      it 'returns nil' do
        expect(subject).to be_nil
      end
    end
  end

  describe '#autodiscover_website_contents' do
    let(:autodiscoverer) { described_class.new(site) }

    before do
      expect(autodiscoverer).to receive(:autodiscover_favicon_url)
    end

    it 'calls the expected methods' do
      autodiscoverer.autodiscover_website_contents
    end
  end

  describe '#run' do
    context 'when domain contains valid hostname' do
      let(:domain) { 'search.gov/with-path' }
      let(:url) { "https://#{domain}" }

      before do
        allow(site).to receive(:default_autodiscovery_url).and_return(url)
        expect(DocumentFetcher).to receive(:fetch)
          .with(url)
          .and_return(last_effective_url: url, body: '')
      end

      it 'should update website' do
        expect(site).to receive(:update!).with(website: url)
        expect(autodiscoverer).to receive(:autodiscover_website_contents)
        autodiscoverer.run
      end
    end

    context 'when valid hostname require www. prefix' do
      let(:domain) { 'search.gov' }
      let(:url) { 'http://www.search.gov' }
      let(:response) { { body: '', last_effective_url: url, status: '301 Moved Permanently' } }

      before do
        allow(site).to receive(:default_autodiscovery_url).and_return("http://#{domain}")
        expect(DocumentFetcher).to receive(:fetch).with("http://#{domain}").and_return({})
        expect(DocumentFetcher).to receive(:fetch).with(url).and_return(response)
      end

      it 'should update website' do
        expect(site).to receive(:update!).with(website: url)
        expect(autodiscoverer).to receive(:autodiscover_website_contents)
        autodiscoverer.run
      end
    end

    context 'when website response status code is 301' do
      let(:domain) { 'search.gov' }
      let(:url) { "http://#{domain}" }

      let(:updated_url) { "http://www.#{domain}" }
      let(:response) { { body: '', status: '301 Moved Permanently', last_effective_url: updated_url } }

      before do
        allow(site).to receive(:default_autodiscovery_url).and_return(url)
        expect(DocumentFetcher).to receive(:fetch).with(url).and_return(response)
      end

      it 'should update website with the last effective URL' do
        expect(site).to receive(:update!).with(website: updated_url)
        expect(autodiscoverer).to receive(:autodiscover_website_contents)
        autodiscoverer.run
      end
    end
  end

  describe '#autodiscover_favicon_url' do
    let(:domain) { 'www.usa.gov' }
    let(:url) { "https://#{domain}" }
    let(:autodiscovery_url) { url }

    context 'when the favicon link is an absolute path' do
      before do
        page_with_favicon = Rails.root.join('spec/fixtures/html/home_page_with_icon_link.html').read
        expect(DocumentFetcher).to receive(:fetch).with(url).and_return(body: page_with_favicon)
      end

      it "should update the affiliate's favicon_url attribute with the value" do
        expect(site).to receive(:update!)
          .with(favicon_url: 'https://www.usa.gov/resources/images/usa_favicon.gif')
        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when the favicon link is a relative path' do
      let(:page_with_favicon) do
        read_fixture_file('/html/home_page_with_relative_icon_link.html')
      end

      before do
        allow(DocumentFetcher).to receive(:fetch).with(url).
          and_return(body: page_with_favicon)
        allow(site).to receive(:update!)
      end

      it 'should store a full url as the favicon link' do
        expect(site).to receive(:update!)
          .with(favicon_url: 'https://www.usa.gov/resources/images/usa_favicon.gif')
        autodiscoverer.autodiscover_favicon_url
      end

      context 'when no autodiscovery url is provided' do
        let(:site) { affiliates(:usagov_affiliate) }
        let(:autodiscovery_url) { nil }

        it 'stores a full url as the favicon link' do
          autodiscoverer.autodiscover_favicon_url
          expect(site).to have_received(:update!)
            .with(favicon_url: 'https://www.usa.gov/resources/images/usa_favicon.gif')
        end
      end
    end

    context 'when default favicon.ico exists' do
      it "should update the affiliate's favicon_url attribute" do
        page_with_no_links = Rails.root.join('spec/fixtures/html/page_with_no_links.html').read
        expect(DocumentFetcher).to receive(:fetch).with(url).and_return(body: page_with_no_links)

        expect(autodiscoverer).to receive(:open)
          .with('https://www.usa.gov/favicon.ico')
          .and_return File.read("#{Rails.root}/spec/fixtures/ico/favicon.ico")

        expect(site).to receive(:update!)
          .with(favicon_url: 'https://www.usa.gov/favicon.ico')

        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when default favicon.ico does not exist' do
      it "should not update the affiliate's favicon_url attribute" do
        page_with_no_links = Rails.root.join('spec/fixtures/html/page_with_no_links.html').read
        expect(DocumentFetcher).to receive(:fetch).with(url).and_return(body: page_with_no_links)

        expect(autodiscoverer).to receive(:open)
          .with('https://www.usa.gov/favicon.ico')
          .and_raise('Some Exception')
        expect(site).not_to receive(:update!)

        autodiscoverer.autodiscover_favicon_url
      end
    end

    context 'when something goes horribly wrong' do
      before do
        allow(autodiscoverer).to receive(:extract_favicon_url).and_raise(NoMethodError)
        allow(Rails.logger).to receive(:error)
      end

      it 'logs an error' do
        autodiscoverer.autodiscover_favicon_url
        expect(Rails.logger).to have_received(:error).with("Error when autodiscovering favicon for #{site.name}", instance_of(NoMethodError))
      end
    end
  end

end
