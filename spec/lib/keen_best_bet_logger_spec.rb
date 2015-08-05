require 'spec_helper'

describe KeenLogger do
  describe '#log(collection, keen_hash)' do
    it 'should log to Keen' do
      Keen.should_receive(:publish_async).with(:impressions, { :some => 'hash' })
      KeenLogger.log(:impressions, { :some => 'hash' })
    end

    context 'when there is a problem with EventMachine that raises a Keen::Error' do
      before do
        Keen.stub(:publish_async).and_raise Keen::Error.new('foo')
      end

      it 'should catch the exception and log the error' do
        Rails.logger.should_receive(:error)
        KeenLogger.log(:clicks, { :some => 'hash' })
      end
    end

    context 'when there is a problem with EventMachine that raises a RuntimeError' do

      before do
        Keen.stub(:publish_async).and_raise RuntimeError.new('foo')
      end

      it 'should catch the exception and log the error' do
        Rails.logger.should_receive(:error)
        KeenLogger.log(:clicks, { :some => 'hash' })
      end
    end
  end
end
