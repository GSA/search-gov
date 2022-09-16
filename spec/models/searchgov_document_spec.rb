# frozen_string_literal: true

require 'spec_helper'

describe SearchgovDocument do
  let(:valid_attributes) do
    {
      web_document: 'Document body',
      headers: { content_type: 'text/plain',
                 etag: '123' },
      searchgov_url_id: 1
    }
  end
  let(:doc) { described_class.new(valid_attributes) }

  describe 'schema' do
    it { is_expected.to have_db_column(:web_document).of_type(:text) }
    it { is_expected.to have_db_column(:headers).of_type(:json) }
    it { is_expected.to have_db_column(:tika_version).of_type(:decimal) }
    it { is_expected.to have_db_index(:searchgov_url_id) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(doc).to be_valid
    end

    it { is_expected.to validate_presence_of :web_document }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:searchgov_url) }
  end

  describe 'accessors' do
    context 'when the header includes an entity tag' do
      it 'assigns an entity tag' do
        expect(doc.etag).to eq('123')
      end
    end
  end
end
