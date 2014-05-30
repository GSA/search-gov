require 'spec_helper'

describe RtuMonthlyReport do
  fixtures :affiliates

  let(:site) { affiliates(:basic_affiliate) }
  let(:rtu_monthly_report) { RtuMonthlyReport.new(site, '2014','5') }

  describe "counts" do
    describe "#total_queries" do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/count.json")) }

      before do
        ES::client_reader.stub(:count).and_return(json_response)
      end

      it 'should return RTU query counts for given month' do
        rtu_monthly_report.total_queries.should == 62330
      end
    end

    describe "#total_clicks" do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/count.json")) }

      before do
        ES::client_reader.stub(:count).and_return(json_response)
      end

      it 'should return RTU click counts for given month' do
        rtu_monthly_report.total_clicks.should == 62330
      end
    end

    context 'when count is not available' do
      before do
        ES::client_reader.stub(:count).and_raise StandardError
      end

      it 'should return nil' do
        rtu_monthly_report.total_queries.should be_nil
        rtu_monthly_report.total_clicks.should be_nil
      end
    end

  end

end
