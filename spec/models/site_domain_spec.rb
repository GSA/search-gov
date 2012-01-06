require 'spec/spec_helper'

describe SiteDomain do
  fixtures :affiliates

  it { should belong_to :affiliate }

  describe "#create" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    ['','foo..gov','weird.tldee'].each do |bad|
      it { should_not allow_value(bad).for(:domain) }
    end
    ['.gov','usa.gov','some.gov/url'].each do |good|
      it { should allow_value(good).for(:domain) }
    end
    specify { affiliate.site_domains.create!(:domain => 'usa.gov').site_name.should == 'usa.gov' }

    context "when domain starts with /https?/" do
      %w( http://USA.gov https://usa.gov).each do |domain|
        subject { affiliate.site_domains.create!(:domain => domain) }

        its(:domain) { should == 'usa.gov' }
        its(:site_name) { should == 'usa.gov' }
      end
    end
  end

  describe "#save" do
    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:site_domain) { affiliate.site_domains.create!(:domain => 'usa.gov', :site_name => 'The Official Search Engine') }

    it "should populate site_name" do
      site_domain.update_attributes(:domain => 'search.usa.gov', :site_name => nil).should be_true
      site_domain.site_name.should == 'search.usa.gov'
    end
  end

  describe ".process_file" do
    let(:affiliate) { affiliates(:basic_affiliate) }
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
                                                                    :error_message => 'Invalid file format; please upload a csv file (.csv).' } }
    end

    context "when content type is not csv" do
      let(:content_type) { 'text/xml' }

      specify { SiteDomain.process_file(affiliate, file).should == { :success => false,
                                                                     :error_message => 'Invalid file format; please upload a csv file (.csv).' } }
    end

    context "when content type is csv and successfully added domains" do
      let(:content_type) { 'text/csv' }

      before do
        affiliate.should_receive(:add_site_domains).with(hash_including('gsa.gov' => nil, 'search.usa.gov' => 'The Official Search Engine')).and_return([site_domain, site_domain])
      end

      specify { SiteDomain.process_file(affiliate, file).should == { :success => true, :added => 2 } }
    end

    context "when content type is csv and there is an existing domain" do
      let(:content_type) { 'text/csv' }

      before do
        affiliate.site_domains.create!(:domain => 'gsa.gov')
        affiliate.should_receive(:add_site_domains).with(hash_including('gsa.gov' => nil, 'search.usa.gov' => 'The Official Search Engine')).and_return([site_domain])
      end

      specify { SiteDomain.process_file(affiliate, file).should == { :success => true, :added => 1 } }
    end
  end
end
