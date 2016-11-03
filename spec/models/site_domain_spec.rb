require 'spec_helper'

describe SiteDomain do
  fixtures :affiliates, :features
  let(:affiliate) { affiliates(:basic_affiliate) }

  it_behaves_like "a search domain object"

  describe "#create" do
    context "when covering/duplicate domain already exists" do
      before do
        affiliate.site_domains.destroy_all
        affiliate.site_domains.create!(:domain => 'usa.gov')
        affiliate.site_domains.create!(:domain => '.mil')
        affiliate.site_domains.create!(:domain => 'test.gov/blog')
      end

      it 'should compare domain and path' do
        expect(affiliate.site_domains.build(domain: 'www.usa.gov.staging.net')).to be_valid
        expect(affiliate.site_domains.build(domain: 'test.gov')).to be_valid
        expect(affiliate.site_domains.build(domain: 'demo.test.gov/news')).to be_valid
        expect(affiliate.site_domains.build(domain: 'test.gov/blogger')).to be_valid
      end

      it 'should not allow overlap' do
        affiliate.site_domains.build(:domain => 'usa.gov/subdir').should_not be_valid
        affiliate.site_domains.build(:domain => 'www.usa.gov').should_not be_valid
        affiliate.site_domains.build(:domain => 'usa.gov').should_not be_valid
        affiliate.site_domains.build(:domain => 'dod.mil').should_not be_valid
        expect(affiliate.site_domains.build(domain: 'demo.test.gov/blog/2012')).not_to be_valid
      end
    end
  end

  describe "#save" do
    let(:site_domain) { affiliate.site_domains.create!(:domain => 'usa.gov', :site_name => 'The Official Search Engine') }

    it "should populate site_name" do
      site_domain.update_attributes(:domain => 'search.usa.gov', :site_name => nil).should be true
      site_domain.site_name.should == 'search.usa.gov'
    end

  end

  describe ".process_file" do
    let(:site_domains) { ActiveSupport::OrderedHash['gsa.gov', '', 'search.usa.gov', 'The Official Search Engine'] }
    let(:file) do
      tempfile = Tempfile.new('site_domains.xml')
      site_domains.each do |domain, site_name|
        tempfile.write("#{domain},#{site_name}\n")
      end
      tempfile.close
      tempfile.open
      ActionDispatch::Http::UploadedFile.new(:tempfile => tempfile, :type => content_type)
    end
    let(:site_domain) { mock_model(SiteDomain) }

    context "when the file is nil" do
      specify { SiteDomain.process_file(affiliate, nil).should == { :success => false,
                                                                    :error_message => SiteDomain::INVALID_FILE_FORMAT_MESSAGE } }
    end

    context 'when file is not a valid csv file' do
      let(:content_type) { 'text/csv' }

      before { CSV.should_receive(:parse).and_raise }

      specify { SiteDomain.process_file(affiliate, file).should == { :success => false,
                                                                    :error_message => SiteDomain::INVALID_FILE_FORMAT_MESSAGE } }
    end

    context "when content type is not csv" do
      let(:content_type) { 'text/xml' }

      specify { SiteDomain.process_file(affiliate, file).should == {:success => false,
                                                                    :error_message => 'Invalid file format. Please upload a csv file (.csv).'} }
    end

    context "when content type is csv and successfully added domains" do
      let(:content_type) { 'text/csv' }

      before do
        affiliate.should_receive(:add_site_domains).with(hash_including('gsa.gov' => nil, 'search.usa.gov' => 'The Official Search Engine')).and_return([site_domain, site_domain])
      end

      specify { SiteDomain.process_file(affiliate, file).should == {:success => true, :added => 2} }
    end

    context "when content type is csv and there is an existing domain" do
      let(:content_type) { 'text/csv' }

      before do
        affiliate.site_domains.create!(:domain => 'gsa.gov')
        affiliate.should_receive(:add_site_domains).with(hash_including('gsa.gov' => nil, 'search.usa.gov' => 'The Official Search Engine')).and_return([site_domain])
      end

      specify { SiteDomain.process_file(affiliate, file).should == {:success => true, :added => 1} }
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
