require 'spec_helper'

describe SiteDomain do
  fixtures :affiliates, :features
  let(:affiliate) { affiliates(:basic_affiliate) }

  it_behaves_like 'a search domain object'

  describe '#create' do
    context 'when covering/duplicate domain already exists' do
      before do
        affiliate.site_domains.destroy_all
        affiliate.site_domains.create!(domain: 'usa.gov')
        affiliate.site_domains.create!(domain: '.mil')
        affiliate.site_domains.create!(domain: 'test.gov/blog')
      end

      it 'should compare domain and path' do
        expect(affiliate.site_domains.build(domain: 'www.usa.gov.staging.net')).to be_valid
        expect(affiliate.site_domains.build(domain: 'test.gov')).to be_valid
        expect(affiliate.site_domains.build(domain: 'demo.test.gov/news')).to be_valid
        expect(affiliate.site_domains.build(domain: 'test.gov/blogger')).to be_valid
      end

      it 'should not allow overlap' do
        expect(affiliate.site_domains.build(domain: 'usa.gov/subdir')).not_to be_valid
        expect(affiliate.site_domains.build(domain: 'www.usa.gov')).not_to be_valid
        expect(affiliate.site_domains.build(domain: 'usa.gov')).not_to be_valid
        expect(affiliate.site_domains.build(domain: 'dod.mil')).not_to be_valid
        expect(affiliate.site_domains.build(domain: 'demo.test.gov/blog/2012')).not_to be_valid
      end
    end
  end

  describe '#save' do
    let(:site_domain) { affiliate.site_domains.create!(domain: 'usa.gov', site_name: 'The Official Search Engine') }

    it 'should populate site_name' do
      expect(site_domain.update_attributes(domain: 'search.usa.gov', site_name: nil)).to be true
      expect(site_domain.site_name).to eq('search.usa.gov')
    end

  end

  describe '.process_file' do
    let(:site_domains) { ActiveSupport::OrderedHash['gsa.gov', '', 'search.usa.gov', 'The Official Search Engine'] }
    let(:file) do
      tempfile = Tempfile.new('site_domains.xml')
      site_domains.each do |domain, site_name|
        tempfile.write("#{domain},#{site_name}\n")
      end
      tempfile.close
      tempfile.open
      Rack::Test::UploadedFile.new(tempfile, content_type)
    end
    let(:site_domain) { mock_model(described_class) }

    context 'when the file is nil' do
      specify { expect(described_class.process_file(affiliate, nil)).to eq({ success: false,
                                                                    error_message: SiteDomain::INVALID_FILE_FORMAT_MESSAGE }) }
    end

    context 'when file is not a valid csv file' do
      let(:content_type) { 'text/csv' }

      before { expect(CSV).to receive(:parse).and_raise }

      specify { expect(described_class.process_file(affiliate, file)).to eq({ success: false,
                                                                    error_message: SiteDomain::INVALID_FILE_FORMAT_MESSAGE }) }
    end

    context 'when content type is not csv' do
      let(:content_type) { 'text/xml' }

      specify { expect(described_class.process_file(affiliate, file)).to eq({success: false,
                                                                    error_message: 'Invalid file format. Please upload a csv file (.csv).'}) }
    end

    context 'when content type is csv and successfully added domains' do
      let(:content_type) { 'text/csv' }

      before do
        expect(affiliate).to receive(:add_site_domains).with(hash_including('gsa.gov' => nil, 'search.usa.gov' => 'The Official Search Engine')).and_return([site_domain, site_domain])
      end

      specify { expect(described_class.process_file(affiliate, file)).to eq({success: true, added: 2}) }
    end

    context 'when content type is csv and there is an existing domain' do
      let(:content_type) { 'text/csv' }

      before do
        affiliate.site_domains.create!(domain: 'gsa.gov')
        expect(affiliate).to receive(:add_site_domains).with(hash_including('gsa.gov' => nil, 'search.usa.gov' => 'The Official Search Engine')).and_return([site_domain])
      end

      specify { expect(described_class.process_file(affiliate, file)).to eq({success: true, added: 1}) }
    end
  end

  describe '#dup' do
    let(:original_instance) do
      affiliate.site_domains.create!(domain: 'usa.gov',
                                     site_name: 'The Official Search Engine')
    end

    include_examples 'site dupable'
  end
end
