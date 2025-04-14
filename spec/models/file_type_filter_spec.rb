# frozen_string_literal: true

require 'spec_helper'

describe FileTypeFilter, type: :model do
  describe 'Validations' do
    it 'is valid with a label when enabled' do
      file_type_filter = described_class.new(label: 'Some label', enabled: true)
      expect(file_type_filter).to be_valid
    end

    it 'uses the default label if none is provided but enabled is true' do
      file_type_filter = described_class.new(enabled: true)
      expect(file_type_filter).to be_valid
      expect(file_type_filter.label).to eq('FileTypeFilter')
    end

    context 'when label is blank and enabled is true' do
      it 'uses the default label' do
        file_type_filter = described_class.new(label: '', enabled: true)
        file_type_filter.save
        file_type_filter.reload

        expect(file_type_filter.label).to eq('FileTypeFilter') 
      end
    end
  end
end
