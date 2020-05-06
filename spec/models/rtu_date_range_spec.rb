require 'spec_helper'

describe RtuDateRange do
  let(:rtu_date_range) { RtuDateRange.new('some affiliate', 'search or click type here') }

  shared_context 'when dates are available' do
    let(:json_response) do
      JSON.parse(
        read_fixture_file('/json/rtu_dashboard/rtu_date_range.json')
      )
    end
    let(:search_opts) do
      {
        index: 'logstash-*',
        body: 'query_body',
        size: 0
      }
    end

    before do
      allow(RtuDateRangeQuery).to receive(:new).
        with('some affiliate', 'search or click type here').
        and_return(instance_double(RtuDateRangeQuery, body: 'query_body'))
      allow(ES::ELK.client_reader).to receive(:search).
        with(search_opts).and_return json_response
    end
  end


  describe "#available_dates_range" do
    context "when dates are available" do
      include_context 'when dates are available'

      it 'should return the range of available dates' do
        expect(rtu_date_range.available_dates_range).to eq(Date.parse('2014-05-20')..Date.parse('2014-05-28'))
      end
    end

    context "when no dates are available" do
      let(:json_response) do
        JSON.parse(read_fixture_file('/json/rtu_dashboard/rtu_date_range_no_stats.json'))
      end

      before do
        allow(ES::ELK.client_reader).to receive(:search).and_return json_response
      end

      it 'should return the range of available dates bounded by current day' do
        expect(rtu_date_range.available_dates_range).to eq(Date.current..Date.current)
      end
    end

    context "when there is a problem getting the data" do
      before do
        allow(ES::ELK.client_reader).to receive(:search).and_raise StandardError
      end

      it 'should return the range of available dates bounded by current day' do
        expect(rtu_date_range.available_dates_range).to eq(Date.current..Date.current)
      end
    end
  end

  describe '#default_start' do
    context 'when dates are available' do
      include_context 'when dates are available'

      it 'is the first day of the most recent month with results' do
        expect(rtu_date_range.default_start).to eq '2014-05-01'.to_date
      end
    end
  end

  describe '#default_end' do
    context 'when dates are available' do
      include_context 'when dates are available'

      it 'is the last day of the available dates' do
        expect(rtu_date_range.default_end).to eq '2014-05-28'.to_date
      end
    end
  end
end
