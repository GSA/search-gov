describe FaradayMiddleware::ExceptionNotifier do
  let(:connection) do
    Faraday.new do |faraday|
      faraday.use  FaradayMiddleware::ExceptionNotifier
      faraday.adapter :net_http_persistent
    end
  end

  context 'when the request fails' do
    let(:error) { Faraday::ClientError.new('failure') }

    before do
      allow(ExceptionNotifier).to receive(:notify_exception)
      stub_request(:any, 'fail.gov').to_raise(error)
    end

    it 'reports the error' do
      connection.get 'http://fail.gov' rescue nil
      expect(ExceptionNotifier).to have_received(:notify_exception).
        with(error, tags: [])
    end

    context 'when tags are provided' do
      let(:connection) do
        Faraday.new do |faraday|
          faraday.use  FaradayMiddleware::ExceptionNotifier, ['testing']
          faraday.adapter :net_http_persistent
        end
      end

      it 'sends the tags' do
        connection.get 'http://fail.gov' rescue nil
        expect(ExceptionNotifier).to have_received(:notify_exception).
          with(error, tags: ['testing'])
      end
    end
  end
end
