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
    it do
      is_expected.to have_db_column(:web_document).
        of_type(:text).with_options(null: false, limit: 4_294_967_295)
    end

    it { is_expected.to have_db_column(:headers).of_type(:json).with_options(null: false) }

    it do
      is_expected.to have_db_column(:tika_version).
        of_type(:decimal).with_options(precision: 10, scale: 4, default: nil)
    end

    it { is_expected.to have_db_index(:searchgov_url_id) }
  end

  describe 'validations' do
    it 'is valid with valid attributes' do
      expect(doc).to be_valid
    end

    it { is_expected.to validate_presence_of :web_document }
    it { is_expected.to validate_presence_of :headers }
  end

  describe 'associations' do
    it { is_expected.to belong_to(:searchgov_url) }
  end

  describe 'accessors' do
    it 'assigns an entity tag' do
      expect(doc.etag).to eq('123')
    end
  end
end
