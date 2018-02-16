require 'spec_helper'

describe Duration do
  describe '.seconds_to_hoursminssecs' do
    it 'returns nil when duration_in_seconds is 0' do
      expect(Duration.seconds_to_hoursminssecs(0)).to be_nil
    end

    it 'returns 00:{seconds} when duration_in_seconds is less than 60' do
      expect(Duration.seconds_to_hoursminssecs(8)).to eq('0:08')
    end

    it 'returns {minutes}:{seconds} when duration_in_seconds < 3600' do
      expect(Duration.seconds_to_hoursminssecs(122)).to eq('2:02')
    end

    it 'returns {hours}:{minutes}:{seconds} when duration_in_seconds >= 3600' do
      expect(Duration.seconds_to_hoursminssecs(3678)).to eq('1:01:18')
    end
  end
end
