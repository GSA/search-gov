require 'spec_helper'

describe DocumentCollectionsHelper do
  fixtures :document_collections, :affiliates

  let(:collection) { document_collections(:usagov_docs) }
  let(:site) { collection.affiliate }

  describe '#link_to_preview_collection' do
    subject { helper.link_to_preview_collection(site, collection) }
    let(:link) do
      "<a href=\"http://test.host/search/docs?affiliate=usagov&amp;dc=#{collection.id}&amp;query=government\" target=\"_blank\">Preview</a>"
    end

    it { should eq link }

    context 'when the site is search consumer enabled' do
      before { site.update_attribute(:search_consumer_search_enabled, true) }
      let(:sc_preview_link) do
        "<a href=\"http://test.host/c/search/docs?affiliate=usagov&amp;dc=#{collection.id}&amp;query=government\" target=\"_blank\">Preview</a>"
      end

      it { should eq sc_preview_link }
    end
  end
end
