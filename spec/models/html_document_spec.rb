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
  let(:doc_without_language) { '<html>هذه الجملة باللغة العربية.</html>' }

  it_should_behave_like 'a web document'

  describe '#title' do
    subject(:title) { html_document.title }

    context 'when no title is available' do
      let(:raw_document) { read_fixture_file('/html/page_without_title.html') }

      it 'returns the url' do
        expect(title).to eq url
      end
    end

    context 'when an open graph title is available' do
      let(:raw_document) { read_fixture_file('/html/page_with_og_metadata.html') }

      it 'returns the open graph title' do
        expect(title).to eq 'My OG Title'
      end
    end
  end

  describe '#description' do
    subject(:description) { html_document.description }

    context 'when an open graph description is available' do
      let(:raw_document) { read_fixture_file('/html/page_with_og_metadata.html') }

      it 'returns the open graph description' do
        expect(description).to eq 'My OG Description'
      end
    end
  end

  describe '#created' do
    subject(:created) { html_document.created }

    it { should eq nil }

    context 'when the publication date is available' do
      let(:raw_document) { read_fixture_file('/html/page_with_og_metadata.html') }

      it { should eq "2015-07-02T10:12:32-04:00" }
     end
  end

  describe '#noindex?' do
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
