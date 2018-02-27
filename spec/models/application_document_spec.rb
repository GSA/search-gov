require 'spec_helper'

describe ApplicationDocument do
  let(:raw_document) { open_fixture_file("/pdf/test.pdf") }
  let(:url) { 'https://foo.gov/bar.pdf' }
  let(:valid_attributes) do
    {
      document: raw_document,
      url: url,
    }
  end
  let(:application_document) { ApplicationDocument.new(valid_attributes) }
  let(:doc_without_description) { open_fixture_file("/pdf/no_metadata.pdf") }
  let(:doc_without_language) { open_fixture_file("/pdf/arabic.pdf") }
  let(:doc_with_lang_subcode) { open_fixture_file("/pdf/lang_subcode.pdf") }

  it_should_behave_like 'a web document'

  describe '#title' do
    subject(:title) { application_document.title }

    context 'when no title is available' do
      let(:raw_document) { open_fixture_file('/pdf/no_metadata.pdf') }

      it 'returns the url' do
        expect(application_document.title).to eq "bar.pdf"
      end

      it { is_expected.to eq 'bar.pdf' }
    end

    context 'when the title is blank' do
      let(:raw_document) { open_fixture_file('/pdf/blank_title.pdf') }

      it { is_expected.to eq 'bar.pdf' }
    end

    context 'when given an array of titles' do
      let(:raw_document) { open_fixture_file('/pdf/title_array.pdf') }

      it { is_expected.to eq 'mm9112' }
    end
  end

  describe '#created' do
    subject(:created) { application_document.created }

    it { is_expected.to eq "2017-09-07T23:26:04Z" }
  end

  describe '#noindex?' do
    subject(:noindex) { application_document.noindex? }

    it { is_expected.to eq false }
  end

  describe '#language' do
    subject(:language) { application_document.language }

    context 'when the language is the full language name' do
      let(:raw_document) { open_fixture_file('/word/language_name.docx') }

      it 'returns the abbreviated language' do
        expect(language).to eq 'en'
      end
    end
  end

  describe '#parsed_content' do
    subject(:parsed_content) { application_document.parsed_content }

    context 'when the file contains non-UTF8 characters' do
      let(:raw_document) { open_fixture_file("/pdf/garbage_chars.pdf") }

      it 'scrubs the characters' do
        expect(parsed_content).not_to match(/\uFFFD/)
      end
    end
  end
end
