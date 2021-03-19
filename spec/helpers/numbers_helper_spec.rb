require 'spec_helper'

describe NumbersHelper, '#non_zero_number_with_delimiter' do
  context 'when number is zero' do
    it 'should return the zero label' do
      expect(helper.non_zero_number_with_delimiter(0, 'nada')).to eq('nada')
      expect(helper.non_zero_number_with_delimiter(0)).to eq('n/a')
    end
  end

  context 'when number is non-zero' do
    it 'should return the delimited number' do
      expect(helper.non_zero_number_with_delimiter(1000)).to eq('1,000')
    end
  end
end