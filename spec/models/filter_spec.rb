# frozen_string_literal: true

require 'spec_helper'

describe Filter, type: :model do
  describe 'Associations' do
    it { should belong_to(:filter_setting) }
  end

  describe 'Validations' do
    context 'label presence' do
      it 'requires a label when enabled' do
        filter = Filter.new(enabled: true, label: nil)
        expect(filter).not_to be_valid
        expect(filter.errors[:label]).to include("can't be blank")
      end

      it 'does not require a label when not enabled' do
        filter = Filter.new(enabled: false, label: nil)
        expect(filter).to be_valid
      end
    end

    context 'custom filter labels' do
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

  describe 'Callbacks' do
    context 'before validation - set_default_label' do
      it 'sets the default label to the type when label is blank and enabled is true' do
        filter = Filter.new(type: 'FileTypeFilter', enabled: true, label: nil)
        filter.valid?
        expect(filter.label).to eq('FileTypeFilter')
      end

      it 'does not overwrite an existing label' do
        filter = Filter.new(type: 'FileTypeFilter', enabled: true, label: 'Custom Label')
        filter.valid?
        expect(filter.label).to eq('Custom Label')
      end

      it 'does nothing if not enabled' do
        filter = Filter.new(type: 'FileTypeFilter', enabled: false, label: nil)
        filter.valid?
        expect(filter.label).to be_nil
      end
    end
  end
end