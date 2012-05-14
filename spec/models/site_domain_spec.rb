require 'spec/spec_helper'

describe SiteDomain do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  it { should belong_to :affiliate }

  describe "#create" do
    it { should validate_presence_of :domain }

    %w(foo..gov weird.tldee some.gov/page.html usda.gov/nal/index.php?info=4&t=1&ts=358 dod.mil/p/mhf?sd=20.0.0 some.mil/?sd=20 bts.gov/x/.).each do |bad|
      it { should_not allow_value(bad).for(:domain) }
    end
    %w(foo.gov .mil www.bar.gov www.bar.gov/subdir blat.gov/subdir).each do |good|
      it { should allow_value(good).for(:domain) }
    end
    specify { affiliate.site_domains.create!(:domain => 'usa.gov').site_name.should == 'usa.gov' }
    specify { affiliate.site_domains.create!(:domain => 'usa.gov/subdir/').domain.should == 'usa.gov/subdir' }

    context "when domain starts with /https?/" do
      %w(http://USA.gov https://usa.gov).each do |domain|
        subject { affiliate.site_domains.create!(:domain => domain) }

        its(:domain) { should == 'usa.gov' }
        its(:site_name) { should == 'usa.gov' }
      end
    end

    context "when covering/duplicate domain already exists" do
      before do
        affiliate.site_domains.destroy_all
        affiliate.site_domains.create!(:domain => 'usa.gov')
        affiliate.site_domains.create!(:domain => '.mil')
      end

      it "should not be valid" do
        affiliate.site_domains.build(:domain => 'usa.gov/subdir').should_not be_valid
        affiliate.site_domains.build(:domain => 'www.usa.gov').should_not be_valid
        affiliate.site_domains.build(:domain => 'usa.gov').should_not be_valid
        affiliate.site_domains.build(:domain => 'dod.mil').should_not be_valid
      end
    end
  end

  describe "#save" do
    let(:site_domain) { affiliate.site_domains.create!(:domain => 'usa.gov', :site_name => 'The Official Search Engine') }

    it "should populate site_name" do
      site_domain.update_attributes(:domain => 'search.usa.gov', :site_name => nil).should be_true
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
      specify { SiteDomain.process_file(affiliate, nil).should == {:success => false,
                                                                   :error_message => 'Invalid file format; please upload a csv file (.csv).'} }
    end

    context "when content type is not csv" do
      let(:content_type) { 'text/xml' }

      specify { SiteDomain.process_file(affiliate, file).should == {:success => false,
                                                                    :error_message => 'Invalid file format; please upload a csv file (.csv).'} }
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

  describe "#populate" do
    let(:site_domain) { affiliate.site_domains.create!(:domain => "foo.gov") }
    let(:frontier) { %w(http://foo.gov/ http://foo.gov/page.html) }

    before do
      site_domain.should_receive(:get_frontier).and_return frontier
    end

    it "should attempt to create a new IndexedDocument for each link in the frontier" do
      site_domain.populate
      frontier.each { |link| affiliate.indexed_documents.find_by_url(link).should_not be_nil }
    end

    it "should fetch/index the ones that were successfully created" do
      id1 = mock("indexed doc")
      site_domain.stub_chain(:affiliate, :indexed_documents, :create).and_return(id1, nil)
      id1.should_receive(:fetch)
      site_domain.populate
    end
  end

  describe "#url_disallowed?(current_url, robots)" do
    let(:current_url) { URI.parse("http://www.whitehouse.gov/test/page.html") }
    let(:site_domain) { affiliate.site_domains.create!(:domain => "www.whitehouse.gov") }

    context "when the robots hash contains nothing for the domain" do
      it "should update the robots.txt file for that domain" do
        Robot.should_receive(:update_for).with("www.whitehouse.gov").and_return nil
        site_domain.url_disallowed?(current_url, {}).should be_false
      end
    end

    context "when the robots hash contains an entry for the domain" do
      it "should use that entry to determine if URL is allowed" do
        Robot.should_not_receive(:update_for)
        site_domain.url_disallowed?(current_url, {'www.whitehouse.gov' => nil}).should be_false
      end

      context "when the entry is a Robot" do
        let(:robot) { Robot.create!(:domain => 'www.whitehouse.gov', :prefixes => '/test/,/ignoreme/') }
        it "should use that Robot entry to determine if the URL is allowed" do
          site_domain.url_disallowed?(current_url, {'www.whitehouse.gov' => robot}).should be_true
        end
      end
    end
  end

  describe "#get_links_from_html_file(file, current_url, parsed_start_page_url)" do
    let(:parsed_start_page_url) { URI.parse("http://www.agency.gov/test/") }
    let(:current_url) { URI.parse("http://www.agency.gov/test/page.html") }
    let(:site_domain) { affiliate.site_domains.create!(:domain => "www.agency.gov/test") }

    context "when there are links in the file" do
      let(:linky_file) { open(Rails.root.to_s + '/spec/fixtures/html/page_with_pdf_links.html') }

      it "should return an array of eligible links from the HTML file" do
        links = %w(http://www.agency.gov/test/another_relative.html http://www.agency.gov/test/another_absolute.html)
        site_domain.get_links_from_html_file(linky_file, current_url, parsed_start_page_url).should == links
      end
    end

    context "when there are no links in the file" do
      let(:linkless_file) { open(Rails.root.to_s + '/spec/fixtures/html/page_with_no_links.html') }

      it "should return an empty array" do
        site_domain.get_links_from_html_file(linkless_file, current_url, parsed_start_page_url).should == []
      end
    end
  end

  describe "#get_frontier(max_docs = MAX_DOCS_PER_CRAWL)" do
    context "when the site domain starts with a . (e.g., .mil)" do
      let(:site_domain) { affiliate.site_domains.create!(:domain => ".gov") }

      it "should return an empty array" do
        site_domain.get_frontier.should == []
      end
    end

    context "when http://site_domain/ is an HTML page with some links" do
      let(:site_domain) { affiliate.site_domains.create!(:domain => "www.agency.gov") }
      let(:linky_file) { open(Rails.root.to_s + '/spec/fixtures/html/page_with_pdf_links.html') }
      let(:links) { %w(http://www.agency.gov/test/another_relative.html http://www.agency.gov/test/another_absolute.html) }
      let(:sublinks1) { %w(http://www.agency.gov/sub1/dupe.html http://www.agency.gov/sub1/page1.html) }
      let(:sublinks2) { %w(http://www.agency.gov/sub1/dupe.html http://www.agency.gov/sub2/page1.html http://www.agency.gov/sub2/page2.html) }

      before do
        site_domain.stub!(:url_disallowed?).and_return(false)
        site_domain.stub!(:open).and_return(linky_file)
        site_domain.stub!(:get_links_from_html_file).and_return(links, sublinks1, sublinks2)
      end

      it "should return an sorted array of valid/eligible HTML pages reachable from that start URL" do
        site_domain.get_frontier.should == %w(http://www.agency.gov/ http://www.agency.gov/sub1/dupe.html http://www.agency.gov/sub1/page1.html http://www.agency.gov/sub2/page1.html http://www.agency.gov/sub2/page2.html http://www.agency.gov/test/another_absolute.html http://www.agency.gov/test/another_relative.html)
      end

      context "when max_docs is passed in" do
        it "should only return max_docs links" do
          site_domain.get_frontier(3).size.should == 3
        end
      end

      context "when some of the linked URLs are non-HTML content" do
        before do
          linky_file.stub!(:content_type).and_return("text/html","text/html","docx")
        end

        it "should ignore them" do
          site_domain.get_frontier.size.should == 2
        end
      end

      context "when some of the linked URLs are blocked by robots.txt" do
        before do
          site_domain.stub!(:url_disallowed?).and_return(false,false,true)
        end

        it "should ignore them" do
          site_domain.get_frontier.size.should == 2
        end
      end

      context "when there is some problem parsing/processing an URL" do
        before do
          site_domain.stub!(:open).and_raise Exception.new("Some other problem")
        end

        it "should log the problem" do
          Rails.logger.should_receive(:warn)
          site_domain.get_frontier
        end
      end

    end
  end
end