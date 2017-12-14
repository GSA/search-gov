require 'spec_helper'

describe 'bulk index urls into Search.gov' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/searchgov')
    Rake::Task.define_task(:environment)
  end

  describe 'searchgov:bulk_index' do
    let(:file_path) { File.join(Rails.root.to_s, "spec", "fixtures", "csv", "searchgov_urls.csv") }
    let(:task_name) { 'searchgov:bulk_index' }
    let(:url) { 'https://www.consumerfinance.gov/consumer-tools/auto-loans/' }
    let(:searchgov_url) { double(SearchgovUrl) }
    let(:index_urls) do
      @rake[task_name].reenable
      @rake[task_name].invoke(file_path, 0)
    end

    before do
      SearchgovUrl.stub(:create!).with(url: url).and_return(searchgov_url)
      SearchgovUrl.stub(:create!).and_call_original
      SearchgovUrl.any_instance.stub(:fetch).and_return(true)
    end

    after { $stdout = STDOUT }

    it "should have 'environment' as a prereq" do
      @rake[task_name].prerequisites.should include("environment")
    end

    it 'creates a SearchgovUrl record' do
      index_urls
      expect(SearchgovUrl.find_by_url(
        'https://www.consumerfinance.gov/consumer-tools/auto-loans/'
      )).not_to be_nil
    end

    context 'when a url has already been indexed' do
      before { $stdout = StringIO.new }

      it 'reports the url as a dupe' do
        index_urls
        expect($stdout.string).to match(/Url has already been taken/)
      end
    end
  end

  describe 'searchgov:promote' do
    let(:file_path) { File.join(Rails.root.to_s, "spec", "fixtures", "csv", "searchgov_urls.csv") }
    let(:task_name) { 'searchgov:promote' }
    let(:url) { 'https://www.consumerfinance.gov/consumer-tools/auto-loans/' }
    let(:doc_id) { SearchgovUrl.new(url: url).document_id }
    let(:promote_urls) do
      @rake[task_name].reenable
      @rake[task_name].invoke(file_path)
    end
    let(:demote_urls) do
      @rake[task_name].reenable
      @rake[task_name].invoke(file_path, 'false')
    end

    it 'can promote urls' do
      expect(I14yDocument).to receive(:promote).
        with(handle: 'searchgov', document_id: doc_id, bool: 'true').at_least(:once)
      promote_urls
    end

    it 'can demote urls' do
      expect(I14yDocument).to receive(:promote).
        with(handle: 'searchgov', document_id: doc_id, bool: 'false').at_least(:once)
      demote_urls
    end

    it 'indexes new urls' do
      allow(I14yDocument).to receive(:promote).
        with(handle: 'searchgov', document_id: doc_id, bool: 'true').at_least(:once)
      expect{ promote_urls }.to change{ SearchgovUrl.count }.from(0).to(1)
    end

    it 'creates new urls' do
      expect(I14yDocument).to receive(:create)
      allow(I14yDocument).to receive(:promote).
        with(handle: 'searchgov', document_id: doc_id, bool: 'true').at_least(:once)
      promote_urls
    end

    context 'when something goes wrong' do
      before do
        SearchgovUrl.any_instance.stub(:fetch).and_raise(StandardError)
        $stdout = StringIO.new
      end
      after { $stdout = STDOUT }

      it 'logs the failure' do
        promote_urls
        expect($stdout.string).
          to match %r(Failed to promote https://www.consumerfinance.gov/consumer-tools/auto-loans/)
      end
    end
  end
end
