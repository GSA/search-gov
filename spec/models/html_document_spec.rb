require 'spec_helper'

describe HtmlDocument do
  let(:web_page) { read_fixture_file("/html/page_with_metadata.html") }
  let(:url) { 'https://foo.gov/bar.html' }
  let(:valid_attributes) do
    { document: web_page, url: url }
  end
  subject(:html_document) { HtmlDocument.new(valid_attributes) }
  let(:doc_without_description) { read_fixture_file("/html/page_with_no_links.html") }

  it_should_behave_like 'a web document'

  describe '#title' do
    context 'when no title is available' do
      let(:web_page) { read_fixture_file('/html/page_without_title.html') }

      it 'returns the url' do
        expect(html_document.title).to eq url
      end
    end
  end
end
