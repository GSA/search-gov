require 'spec_helper'

describe Template do
  describe 'schema' do
    it { should have_db_column(:name).of_type(:string).with_options(null: false, limit: 50, index: true, unique: true) }
    it { should have_db_column(:klass).of_type(:string).with_options(null: false, limit: 50, index: true, unique: true) }
    it { should have_db_column(:description).of_type(:string).with_options(null: false) }
    it { should have_db_column(:schema).of_type(:text).with_options(null: false) }
  end

  describe 'validations' do
    it { should validate_presence_of :name }
    it { should validate_presence_of :klass }
    it { should validate_presence_of :schema }
    it { should validate_uniqueness_of :name }
    it { should validate_uniqueness_of :klass }
  end

  describe 'associations' do
    it { should have_many(:affiliates) }
    it { should have_many(:affiliate_templates).dependent(:destroy) }
  end

  it { should have_readonly_attribute(:klass) }
end
