require 'spec/spec_helper'

describe IndexedDomainTemplateDetector do
  fixtures :indexed_domains
  let(:indexed_domain) { indexed_domains(:sample) }
  let(:idtd) { IndexedDomainTemplateDetector.new(indexed_domain) }

  describe "self.perform(indexed_domain_id)" do
    before do
      idtd = IndexedDomainTemplateDetector.new(indexed_domain)
      indexed_domain.common_substrings.create!(:substring => "existing entry with nav elements", :saturation => 70.1)
      IndexedDomainTemplateDetector.stub!(:new).and_return(idtd)
      cs = CommonSubstring.new(:substring => "existing entry with nav elements", :saturation => 99.9)
      idtd.stub!(:detect_common_substring).and_return(cs)
    end

    it "should find one large common substring/template and create a CommonSubstring record from it" do
      IndexedDomainTemplateDetector.perform(indexed_domain.id)
      indexed_domain.common_substrings.find_by_substring("existing entry with nav elements").saturation.should == 99.9
    end
  end

  describe "#detect_common_substring" do
    let(:idtd) { IndexedDomainTemplateDetector.new(indexed_domain) }

    context "when there are fewer than 10 docs that are HTML and OK for the indexed domain" do
      before do
        idtd.stub!(:get_good_html_idocs_ids).and_return 1.upto(9).to_a
      end

      it "should return nil" do
        idtd.detect_common_substring.should == nil
      end
    end

    context "when there are multiple docs for the indexed domain" do
      before do
        idtd.stub!(:get_good_html_idocs_ids).and_return 1.upto(10).to_a
      end

      context "when the substring is long enough and has a high enough saturation percentage" do
        before do
          idtd.stub!(:get_candidate_substrings)
          idtd.stub!(:compute_saturation).and_return 87.65
          idtd.stub!(:get_local_longest_common_substring).and_return "some local LCS with lots of words and a high saturation"
        end

        it "should return a new CommonSubstring object" do
          common_substring = idtd.detect_common_substring
          common_substring.substring.should == "some local LCS with lots of words and a high saturation"
          common_substring.saturation.should == 87.65
        end
      end

      context "when the substring is long enough but the saturation percentage is too low" do
        before do
          idtd.stub!(:get_candidate_substrings)
          idtd.stub!(:compute_saturation).and_return 57.65
          idtd.stub!(:get_local_longest_common_substring).and_return "some local LCS with lots of words and a high saturation"
        end

        it "should return nil" do
          idtd.detect_common_substring.should be_nil
        end
      end

      context "when the substring is too short" do
        before do
          idtd.stub!(:get_candidate_substrings)
          idtd.stub!(:compute_saturation).and_return 97.65
          idtd.stub!(:get_local_longest_common_substring).and_return "some short local LCS"
        end

        it "should return nil" do
          idtd.detect_common_substring.should be_nil
        end
      end

    end
  end

  describe "#get_local_longest_common_substring(candidate_substrings)" do
    let(:idtd) { IndexedDomainTemplateDetector.new(indexed_domain) }
    it "should find the trimmed LCS between the first string in the array and the others that aren't too much shorter" do
      candidate_substrings = ["when there are multiple docs for the indexed domain when the substring is too short should return nil",
                              "there are multiple docs for the indexed domain too short",
                              "more text when there are multiple docs for the indexed domain when the substring is too short should return something",
                              "well, this one does not look like the others",
                              "when there are multiple docs for the indexed domain when the substring is too short should return hello"]
      idtd.get_local_longest_common_substring(candidate_substrings).should == "when there are multiple docs for the indexed domain when the substring is too short should return"
    end
  end

  describe "#get_candidate_substrings(good_html_idocs_ids)" do
    let(:idtd) { IndexedDomainTemplateDetector.new(indexed_domain) }

    before do
      idtd.stub!(:compute_saturation).and_return(51, 20, 30, 40, 50, 60, 70, 80, 99, 15)
      idtd.stub!(:get_candidate_substring_between_random_document_pair).and_return(
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> Contact Us",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> About",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> Info",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> Forms",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> Recalls",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> APIs",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> TOS",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> Jargon",
        "Here's a footer we all love",
        "Here's a footer we all love based on Thijs"
      )
    end

    it "should get sample LCS's from random pairs of documents, with highest saturation first" do
      ary = [
        "Here's a footer we all love",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> Jargon",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> TOS",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> APIs",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> Contact Us",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> Recalls",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> Forms",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> Info",
        "Our Site -> Built By Drupal -> Laden with Huge Templates -> Welcome -> News -> Media -> Amazing -> Breadcrumb -> About",
        "Here's a footer we all love based on Thijs"
      ]
      idtd.get_candidate_substrings(1.upto(100).to_a).should == ary
    end
  end

  describe "#get_candidate_substring_between_random_document_pair(good_html_idocs_ids)" do
    let(:idtd) { IndexedDomainTemplateDetector.new(indexed_domain) }

    before do
      idtd.stub!(:rand).and_return 42
      doc1 = mock_model(IndexedDocument, :body_for_substring_detection => "some body is pretty large in this document")
      doc2 = mock_model(IndexedDocument, :body_for_substring_detection => "some other body is pretty large")
      IndexedDocument.should_receive(:find).with([43, 44]).and_return [doc1, doc2]
    end

    it "should get a sample LCS from a random pair of documents" do
      idtd.get_candidate_substring_between_random_document_pair(1.upto(100).to_a).should == " body is pretty large"
    end
  end

  describe "#compute_saturation(lcs)" do
    fixtures :affiliates
    let(:idtd) { IndexedDomainTemplateDetector.new(indexed_domain) }
    let(:lcs) { " body is pretty large" }

    before do
      affiliate = affiliates(:basic_affiliate)
      affiliate.indexed_documents.destroy_all
      affiliate.features << Feature.find_or_create_by_internal_name('hosted_sitemaps', :display_name => "hs")
      1.upto(3) do |x|
        affiliate.indexed_documents.create!(:url => "http://#{indexed_domain.domain}/page#{x}.html", :title => "Some HTML Title#{x}",
                                            :description => "This is HTML document number #{x}.",
                                            :last_crawl_status => IndexedDocument::OK_STATUS,
                                            :body => "some#{lcs} in this document #{x}",
                                            :doctype => 'html',
                                            :content_hash => "a6e450cc50ac3b3b7788b50b3b73e8b#{x}")
      end
      affiliate.indexed_documents.create!(:url => "http://#{indexed_domain.domain}/page4.html", :title => 'Some HTML Title4',
                                          :description => 'This is HTML document number 4.',
                                          :last_crawl_status => IndexedDocument::OK_STATUS,
                                          :body => "no template on this page",
                                          :doctype => 'html',
                                          :content_hash => "a6e450cc50ac3b3b7788b50b3b73e8b0b4")
    end

    it "should determine what percentage (0.0-100.0) of the indexed domain's documents contain this LCS" do
      idtd.compute_saturation(lcs).should == 75.0
    end
  end

end