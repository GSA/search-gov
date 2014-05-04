require 'spec_helper'

describe Duration do
  describe '.seconds_to_hoursminssecs' do
    it 'returns nil when duration_in_seconds is 0' do
      Duration.seconds_to_hoursminssecs(0).should be_nil
    end

    it 'returns 00:{seconds} when duration_in_seconds is less than 60' do
      Duration.seconds_to_hoursminssecs(8).should == '0:08'
    end

    it 'returns {minutes}:{seconds} when duration_in_seconds < 3600' do
      Duration.seconds_to_hoursminssecs(122).should == '2:02'
    end

    it 'returns {hours}:{minutes}:{seconds} when duration_in_seconds >= 3600' do
      Duration.seconds_to_hoursminssecs(3678).should == '1:01:18'
    end
  end
end
