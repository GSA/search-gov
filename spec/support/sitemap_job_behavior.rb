shared_examples_for 'a sitemap job' do
  let(:args) { nil }

  it 'uses the "sitemap" queue' do
    expect{
      described_class.perform_later(args)
    }.to have_enqueued_job.on_queue('sitemap')
  end
end
