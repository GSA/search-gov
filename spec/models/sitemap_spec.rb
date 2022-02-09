# frozen_string_literal: true

require 'spec_helper'

describe Sitemap do
  let(:url) { 'http://agency.gov/sitemap.xml' }
  let(:valid_attributes) { { url: url } }

  it { is_expected.to have_readonly_attribute(:url) }

  describe 'schema' do
    it do
      is_expected.to have_db_column(:url).of_type(:string).
        with_options(null: false, limit: 2000)
    end
  end

  describe 'validations' do
    context 'when validating url uniqueness' do
      before { described_class.create!(valid_attributes) }

      it 'rejects duplicate urls' do
        expect(described_class.new(valid_attributes)).not_to be_valid
      end

      it 'is not case-sensitive' do
        expect(described_class.new(url: url.upcase)).not_to be_valid
      end
    end
  end

  describe 'lifecycle' do
    describe 'on create' do
      it 'is automatically indexed' do
        expect(SitemapIndexerJob).to receive(:perform_later).with(sitemap_url: url)
        described_class.create!(url: url)
      end
    end
  end

  it_should_behave_like 'a record with a fetchable url'
  it_should_behave_like 'a record that belongs to a searchgov_domain'
end
