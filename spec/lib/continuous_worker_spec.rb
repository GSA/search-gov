require 'spec_helper'

describe ContinuousWorker do
  module MockModule def self.process; end; end
  describe '.start' do
    it 'should raise the error after 3 retries' do
      expect(MockModule).to receive(:process).at_least(:once)
      expect(described_class).to receive(:sleep).with(15.minutes).at_least(:once)
      t = Thread.new { described_class.start { MockModule.process } }
      sleep(0.1)
      t.kill
    end
  end

  describe '.execute_with_retry' do
    it 'should sleep and retry 3 times before raising the error' do
      expect(MockModule).to receive(:process).exactly(4).times.and_raise
      expect(described_class).to receive(:sleep).exactly(3).times.with(300)
      expect { described_class.execute_with_retry { MockModule.process } }.to raise_error
    end
  end
end
