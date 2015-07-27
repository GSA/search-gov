shared_context 'SSL request' do
  before { controller.should_receive(:request_ssl?).and_return(true) }
end
