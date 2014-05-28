require 'spec_helper'

describe RtuDateRange do
  let(:rtu_date_range) { RtuDateRange.new('some affiliate', 'search or click type here') }

  describe "#available_dates_range" do
    context "when dates are available" do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/rtu_date_range.json")) }

      before do
        ES::client_reader.stub(:search).and_return json_response
      end

      it 'should return the range of available dates' do
        rtu_date_range.available_dates_range.should == (Date.parse('2014-05-20')..Date.parse('2014-05-28'))
      end
    end

    context "when no dates are available" do
      let(:json_response) { JSON.parse(File.read("#{Rails.root}/spec/fixtures/json/rtu_dashboard/rtu_date_range_infinity.json")) }

      before do
        ES::client_reader.stub(:search).and_return json_response
      end

      it 'should return the range of available dates bounded by current day' do
        rtu_date_range.available_dates_range.should == (Date.current..Date.current)
      end
    end

    context "when there is a problem getting the data" do
      before do
        ES::client_reader.stub(:search).and_raise StandardError
      end

      it 'should return the range of available dates bounded by current day' do
        rtu_date_range.available_dates_range.should == (Date.current..Date.current)
      end
    end
  end

end