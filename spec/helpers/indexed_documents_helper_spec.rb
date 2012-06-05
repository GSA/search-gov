require 'spec/spec_helper'

describe IndexedDocumentsHelper do
  describe "#render_last_crawl_status" do
    let(:indexed_document) { mock('indexed document') }
    context "when last crawled status is OK" do
      before do
        indexed_document.should_receive(:last_crawl_status).with(no_args).twice.and_return(IndexedDocument::OK_STATUS)
      end

      specify { helper.render_last_crawl_status(indexed_document).should == IndexedDocument::OK_STATUS }
    end

    context "when last crawl status is blank" do
      before do
        indexed_document.should_receive(:last_crawl_status).with(no_args).exactly(3).times.and_return(nil)
      end

      specify { helper.render_last_crawl_status(indexed_document).should be_nil }
    end

    context "when last crawl status starts with Error|" do
      before do
        indexed_document.should_receive(:id).with(no_args).and_return('12345')
        indexed_document.should_receive(:url).with(no_args).and_return('http://some.domain.gov/blog/1')
        indexed_document.should_receive(:last_crawl_status).with(no_args).exactly(3).times.and_return("404 Not Found")
      end

      subject { helper.render_last_crawl_status(indexed_document) }

      it { should have_selector "a", :href => '#', :class => 'dialog-link', :content => 'Error', :dialog_id => 'crawled_url_error_12345' }
      it { should have_selector "span", :class => 'ui-icon ui-icon-newwin' }
      it { should have_selector "div", :class => 'url-error-message hide', :id => 'crawled_url_error_12345' }
    end
  end
end
