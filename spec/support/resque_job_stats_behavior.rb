shared_examples 'a ResqueJobStats job' do
  describe '.around_perform_with_stats' do
    subject(:perform) { described_class.around_perform_with_stats() { job.run } }
    let(:job) { double(run: nil) }
    let(:statsd) { described_class.statsd }

    it 'increments run_count metric' do
      statsd.should_receive(:increment).with('run_count')
      perform
    end

    it 'gauges run_duration time' do
      statsd.should_receive(:time).with('run_duration')
      perform
    end

    it 'does not increment failure_count' do
      statsd.should_not_receive(:increment).with('failure_count')
      perform
    end

    context 'when a failure occurs' do
      before { job.stub(:run).and_raise('something terrible') }

      it 'increments both run_count and failure_count metrics' do
        statsd.should_receive(:increment).with('run_count')
        statsd.should_receive(:increment).with('failure_count')
        begin
          perform
        rescue
        end
      end

      it 'gauges run_duration time' do
        statsd.should_receive(:time).with('run_duration')
        begin
          perform
        rescue
        end
      end

      it 'raises the error' do
        expect { perform }.to raise_error('something terrible')
      end
    end
  end
end
