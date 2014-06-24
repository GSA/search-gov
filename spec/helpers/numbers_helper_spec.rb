require 'spec_helper'

describe NumbersHelper, "#non_zero_number_with_delimiter" do
  context 'when number is zero' do
    it 'should return the zero label' do
      helper.non_zero_number_with_delimiter(0, 'nada').should == 'nada'
      helper.non_zero_number_with_delimiter(0).should == 'n/a'
    end
  end

  context 'when number is non-zero' do
    it 'should return the delimited number' do
      helper.non_zero_number_with_delimiter(1000).should == '1,000'
    end
  end
end