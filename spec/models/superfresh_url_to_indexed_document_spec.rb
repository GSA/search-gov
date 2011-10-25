require 'spec/spec_helper'

describe SuperfreshUrlToIndexedDocument, "#perform(url, affiliate_id)" do
  fixtures :affiliates, :superfresh_urls
  let(:aff) { affiliates(:power_affiliate) }

  context "when it can't locate the Superfresh URL entry for a given url & affiliate_id" do
    let(:url) { "http://www.unknown.gov" }

    it "should ignore the entry" do
      IndexedDocument.should_not_receive(:fetch)
      SuperfreshUrlToIndexedDocument.perform(url, aff.id)
    end
  end

  context "when it can locate the Superfresh URL entry for a given url & affiliate_id" do
    let(:url) { aff.superfresh_urls.first.url }

    it "should attempt to fetch and index the document" do
      IndexedDocument.should_receive(:fetch).with(url, aff.id)
      SuperfreshUrlToIndexedDocument.perform(url, aff.id)
    end
  end
end