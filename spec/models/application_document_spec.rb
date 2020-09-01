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

    it { is_expected.to eq Time.parse('2018-06-09T17:42:11Z') }
  end

  describe '#changed' do
    subject(:changed) { application_document.changed }

    context 'when a creation date is available but not a modification date' do
      let(:raw_document) { open_fixture_file('/pdf/not_modified.pdf') }

      it 'defaults to the created date' do
        expect(changed).to eq Time.parse("2017-09-07T23:26:04Z")
      end
    end

    context 'when the document has been modified' do
      let(:raw_document) { open_fixture_file('/pdf/test.pdf') }

      it { is_expected.to eq Time.parse("2018-06-09T17:42:11Z") }
    end
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

    context 'when an XLS file contains a million empty rows' do #because that's a thing.
      let(:raw_document) { open_fixture_file('/excel/bazillion_empty_lines.xlsx') }

      it 'parses the content' do
        expect(parsed_content).to match(/Chicago/)
      end
    end
  end

  describe 'redirect_url' do
    subject(:redirect_url) { application_document.redirect_url }

    it { is_expected.to be nil }
  end
end
