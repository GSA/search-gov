# frozen_string_literal: true

require 'spec_helper'

describe CustomFilter, type: :model do
  describe 'Validations' do
    it 'is valid with a label when enabled' do
      custom_filter = CustomFilter.new(label: 'Custom Label', enabled: true)
      expect(custom_filter).to be_valid
    end

    it 'uses the default label if none is provided but enabled is true' do
      custom_filter = CustomFilter.new(enabled: true)
      expect(custom_filter).to be_valid
      expect(custom_filter.label).to eq('CustomFilter')
    end

    context 'when label is blank and enabled is true' do
      it 'uses the default label' do
        custom_filter = CustomFilter.new(label: '', enabled: true)
        custom_filter.save
        custom_filter.reload

        expect(custom_filter.label).to eq('CustomFilter')
      end
    end

    it 'does not set a default label when not enabled' do
      custom_filter = CustomFilter.new(enabled: false, label: nil)
      custom_filter.valid?

      expect(custom_filter.label).to be_nil
    end

    it 'does not overwrite an existing label' do
      custom_filter = CustomFilter.new(enabled: true, label: 'My Custom Label')
      custom_filter.valid?

      expect(custom_filter.label).to eq('My Custom Label')
    end
  end
end