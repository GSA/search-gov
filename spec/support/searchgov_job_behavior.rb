shared_examples_for 'a searchgov job' do
  let(:args) { nil }

  it 'uses the "searchgov" queue' do
    expect{
      described_class.perform_later(args)
    }.to have_enqueued_job.on_queue('searchgov')
  end
end
