# frozen_string_literal: true

require 'spec_helper'

describe SearchgovDocument do
  let(:valid_attributes) do
    {
      body: 'Document body',
      searchgov_url_id: 1
    }
  end

  describe 'schema' do
    it { is_expected.to have_db_column(:body).of_type(:text) }
    it { is_expected.to have_db_index(:searchgov_url_id) }
  end

  describe 'validations' do
    let(:doc) do
      described_class.new(valid_attributes)
    end

    it 'is valid with valid attributes' do
      expect(doc).to be_valid
    end

    it 'is not valid without a body' do
      doc.body = nil
      expect(doc).not_to be_valid
    end
  end

  describe 'associations' do
    it { is_expected.to belong_to(:searchgov_url) }
  end

  describe '#initialize' do
    let(:doc) do
      described_class.new(valid_attributes)
    end

    it 'assigns an entity tag if provided in the header' do
      doc.header = { content_type: 'text/plain',
                     Etag: '123' }

      expect(doc.Etag).to eq('123')
    end
  end
end
