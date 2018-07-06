require 'spec_helper'

describe Sitemap do
  let(:url) { 'http://agency.gov/sitemap.xml' }
  let(:valid_attributes) { { url: url } }

  it { is_expected.to have_readonly_attribute(:url) }

  describe 'schema' do
    it { is_expected.to have_db_column(:url).of_type(:string).with_options(null: false, limit: 2000) }
  end

  describe 'validations' do
    context 'when validating url uniqueness' do
      let!(:original) { Sitemap.create!(valid_attributes) }

      it 'rejects duplicate urls' do
        expect(Sitemap.new(valid_attributes)).to_not be_valid
      end

      it 'is not case-sensitive' do
        expect(Sitemap.create!(url: url.upcase)).to be_valid
      end
    end
  end

  it_should_behave_like 'a record with a fetchable url'
  it_should_behave_like 'a record that belongs to a searchgov_domain'
end
