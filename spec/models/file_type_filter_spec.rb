# frozen_string_literal: true

require 'spec_helper'

describe FileTypeFilter, type: :model do
  describe 'Validations' do
    it 'is valid with a label when enabled' do
      file_type_filter = described_class.new(label: 'Some label', enabled: true)
      expect(file_type_filter).to be_valid
    end

    it 'is invalid without a label when enabled' do
      file_type_filter = described_class.new(enabled: true)
      expect(file_type_filter).not_to be_valid
      expect(file_type_filter.errors[:label]).to include("can't be blank")
    end
  end
end