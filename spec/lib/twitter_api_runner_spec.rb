require 'spec_helper'

describe TwitterApiRunner do
  describe '.run' do

    context 'the block raises Twitter::Error::ServiceUnavailable 3 times' do
      it 'should sleep and retry 3 times before raising the error' do
        Twitter.should_receive(:user_timeline).exactly(4).times.and_raise(Twitter::Error::ServiceUnavailable)
        TwitterApiRunner.should_receive(:sleep).exactly(3).times.with(15.minutes)
        lambda { TwitterApiRunner.run { Twitter.user_timeline('usasearch') } }.should raise_error(Twitter::Error::ServiceUnavailable)
      end
    end

    context 'the block raises Twitter::Error::TooManyRequests 3 times' do
      it 'should sleep and retry 3 times before raising the error' do
        error = Twitter::Error::TooManyRequests.new
        error.stub_chain(:rate_limit, :reset_in).and_return(5.minutes)
        Twitter.should_receive(:user_timeline).exactly(4).times.and_raise(error)
        TwitterApiRunner.should_receive(:sleep).exactly(3).times.with(5.minutes + 60)
        lambda { TwitterApiRunner.run { Twitter.user_timeline('usasearch') } }.should raise_error(error)
      end
    end
  end
end