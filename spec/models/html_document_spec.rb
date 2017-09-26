require 'spec_helper'

describe HtmlDocument do
  let(:raw_document) { read_fixture_file("/html/page_with_metadata.html") }
  let(:url) { 'https://foo.gov/bar.html' }
  let(:valid_attributes) do
    { document: raw_document, url: url }
  end
  subject(:html_document) { HtmlDocument.new(valid_attributes) }
  let(:doc_without_description) { read_fixture_file("/html/page_with_no_links.html") }
  let(:doc_with_lang_subcode) { '<html lang="en-US"></html>' }
  let(:doc_without_language) { '<html>no language</html>' }

  it_should_behave_like 'a web document'

  describe '#title' do
    context 'when no title is available' do
      let(:raw_document) { read_fixture_file('/html/page_without_title.html') }

      it 'returns the url' do
        expect(html_document.title).to eq url
      end
    end
  end

  describe 'noindex?' do
    subject(:noindex) { html_document.noindex? }
    context 'when NOINDEX is specified' do
      let(:raw_document) do
        '<html><head><title>...</title><META NAME="ROBOTS" CONTENT="NOINDEX, NOFOLLOW"></head></html>'
      end

      it { should eq true }
    end

    context 'when NONE is specified' do
      let(:raw_document) do
        '<html><head><title>...</title><META NAME="ROBOTS" CONTENT="NONE"></head></html>'
      end

      it { should eq true }
    end

    context 'when NOINDEX is not specified' do
      let(:raw_document) do
        '<html><head><title>...</title><META NAME="ROBOTS" CONTENT="NOFOLLOW"></head></html>'
      end

      it { should eq false }
    end
  end
end
