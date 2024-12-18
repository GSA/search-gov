# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Filter, type: :model do
  describe 'Associations' do
    it { should belong_to(:filter_setting) }
  end

  describe 'validations' do
    it 'requires a label' do
      filter = Filter.new(label: nil)
      expect(filter).not_to be_valid
      expect(filter.errors[:label]).to include("can't be blank")
    end

    it 'requires custom filters to have unique labels when enabled' do
      filter = Filter.new(label: "Custom1", enabled: true)
      expect(filter).not_to be_valid
      expect(filter.errors[:label]).to include('You must customize the label for this custom filter.')
    end

    it 'passes validation for customized label' do
      filter = Filter.new(label: "My Custom Filter", enabled: true)
      expect(filter).to be_valid
    end
  end
end