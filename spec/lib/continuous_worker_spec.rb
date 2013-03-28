require 'spec_helper'

describe ContinuousWorker do
  module MockModule def self.process; end; end
  describe '.start' do
    it 'should raise the error after 3 retries' do
      MockModule.should_receive(:process).at_least(:once)
      ContinuousWorker.should_receive(:sleep).with(15.minutes).at_least(:once)
      t = Thread.new { ContinuousWorker.start { MockModule.process } }
      sleep(0.1)
      t.kill
    end
  end

  describe '.execute_with_retry' do
    it 'should sleep and retry 3 times before raising the error' do
      MockModule.should_receive(:process).exactly(4).times.and_raise
      ContinuousWorker.should_receive(:sleep).exactly(3).times.with(30)
      lambda { ContinuousWorker.execute_with_retry { MockModule.process } }.should raise_error
    end
  end
end