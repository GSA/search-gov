require 'spec_helper'

describe MonthlyReport do

  describe ".new" do
    context 'when year/month are strings' do
      it 'should cast them into integers' do
        MonthlyReport.new(double('Affiliate'),'2013','09').picked_mmyyyy.should == '9/2013'
      end
    end
  end
end
