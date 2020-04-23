require 'spec_helper'

describe RtuClickRawHumanArray do
  let(:click_raw_human_array) { RtuClickRawHumanArray.new('usagov', Date.current, Date.current, 5) }

  describe ".top_clicks" do
    subject(:top_clicks) { click_raw_human_array.top_clicks }

    context 'when data is available' do
      let(:query_args) do
        [
          'usagov',
          'click',
          Date.current,
          Date.current,
          { field: 'params.url', size: 1_000_000 }
        ]
      end

      before do
        allow(RtuTopClicks).to receive(:new).with(anything, false).and_return double(RtuTopClicks, top_n: [['click6', 55], ['click5', 54], ['click4', 14]])
        allow(RtuTopClicks).to receive(:new).with(anything, true).and_return double(RtuTopClicks, top_n: [['click6', 53], ['click5', 50]])
      end

      it 'should return an array of [click, total, human] sorted by desc human' do
        expect(click_raw_human_array.top_clicks).to match_array([['click6', 55, 53], ['click5', 54, 50], ["click4", 14, 0]])
      end

      it 'generates a DateRangeTopNQuery with the expected options' do
        expect(DateRangeTopNQuery).to receive(:new).
          with(*query_args).and_call_original
        top_clicks
      end
    end

    context 'when start_date or end_date is nil' do
      let(:click_raw_human_array) { RtuClickRawHumanArray.new('usagov', nil, nil, 5) }

      it "should return INSUFFICIENT_DATA" do
        expect(click_raw_human_array.top_clicks).to eq(RtuClickRawHumanArray::INSUFFICIENT_DATA)
      end
    end

    context "when there really is insufficient data" do
      let(:click_raw_human_array) { RtuClickRawHumanArray.new('usagov', nil, nil, 5) }

      before do
        allow(RtuTopClicks).to receive(:new).and_return double(RtuTopClicks, top_n: [])
      end

      it "should return INSUFFICIENT_DATA" do
        expect(click_raw_human_array.top_clicks).to eq(RtuClickRawHumanArray::INSUFFICIENT_DATA)
      end
    end
  end
end
