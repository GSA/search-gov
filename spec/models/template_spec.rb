require 'spec_helper'

describe Template do
  describe 'schema' do
    it { is_expected.to have_db_column(:name).of_type(:string).with_options(null: false, limit: 50) }
    it { is_expected.to have_db_column(:klass).of_type(:string).with_options(null: false, limit: 50) }
    it { is_expected.to have_db_column(:description).of_type(:string).with_options(null: false) }
    it { is_expected.to have_db_column(:schema).of_type(:text).with_options(null: false) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :name }
    it { is_expected.to validate_presence_of :klass }
    it { is_expected.to validate_presence_of :schema }
    it { is_expected.to validate_uniqueness_of :name }
    it { is_expected.to validate_uniqueness_of :klass }
  end

  describe 'associations' do
    it { is_expected.to have_many(:affiliates) }
    it { is_expected.to have_many(:affiliate_templates).dependent(:destroy) }
  end

  it { is_expected.to have_readonly_attribute(:klass) }
end
