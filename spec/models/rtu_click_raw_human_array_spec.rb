require 'spec_helper'

describe RtuClickRawHumanArray do

  describe ".top_clicks" do
    context 'when data is available' do
      let(:click_raw_human_array) { RtuClickRawHumanArray.new('usagov', Date.current, Date.current, 5) }

      before do
        allow(RtuTopClicks).to receive(:new).with(anything, false).and_return double(RtuTopClicks, top_n: [['click6', 55], ['click5', 54], ['click4', 14]])
        allow(RtuTopClicks).to receive(:new).with(anything, true).and_return double(RtuTopClicks, top_n: [['click6', 53], ['click5', 50]])
      end

      it 'should return an array of [click, total, human] sorted by desc human' do
        expect(click_raw_human_array.top_clicks).to match_array([['click6', 55, 53], ['click5', 54, 50], ["click4", 14, 0]])
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
