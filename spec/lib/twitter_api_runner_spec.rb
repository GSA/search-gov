require 'spec_helper'

describe TwitterApiRunner do
  describe '.run' do

    context 'the block raises Twitter::Error::ServiceUnavailable' do
      it 'should sleep and retry 3 times before raising the error' do
        expect(Twitter).to receive(:user_timeline).exactly(4).times.and_raise(Twitter::Error::ServiceUnavailable)
        expect(TwitterApiRunner).to receive(:sleep).exactly(3).times.with(15.minutes)
        expect { TwitterApiRunner.run { Twitter.user_timeline('usasearch') } }.to raise_error(Twitter::Error::ServiceUnavailable)
      end
    end

    context 'the block raises Twitter::Error::TooManyRequests' do
      it 'should sleep and retry 3 times before raising the error' do
        error = Twitter::Error::TooManyRequests.new
        allow(error).to receive_message_chain(:rate_limit, :reset_in).and_return(5.minutes)
        expect(Twitter).to receive(:user_timeline).exactly(4).times.and_raise(error)
        expect(TwitterApiRunner).to receive(:sleep).exactly(3).times.with(5.minutes + 60)
        expect { TwitterApiRunner.run { Twitter.user_timeline('usasearch') } }.to raise_error(Twitter::Error::TooManyRequests)
      end
    end

    context 'the block raises Twitter::Error execution expired' do
      it 'should sleep and retry 3 times before raising the error' do
        error = Twitter::Error.new 'execution expired'
        expect(Twitter).to receive(:user_timeline).exactly(4).times.and_raise(error)
        expect(TwitterApiRunner).to receive(:sleep).exactly(3).times.with(15.minutes)
        expect { TwitterApiRunner.run { Twitter.user_timeline('usasearch') } }.to raise_error(Twitter::Error)
      end
    end

    context 'the block raises Twitter::Error something other than execution expired' do
      it 'should raise the error' do
        error = Twitter::Error.new 'bogus error'
        expect(Twitter).to receive(:user_timeline).once.and_raise(error)
        expect(TwitterApiRunner).not_to receive(:sleep)
        expect { TwitterApiRunner.run { Twitter.user_timeline('usasearch') } }.to raise_error(Twitter::Error)
      end
    end
  end
end
