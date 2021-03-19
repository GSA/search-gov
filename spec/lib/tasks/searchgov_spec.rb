require 'spec_helper'

describe 'Search.gov tasks' do
  fixtures :i14y_drawers

  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/searchgov')
    Rake::Task.define_task(:environment)
  end

  before { $stdout = StringIO.new }
  after { $stdout = STDOUT }

  describe 'searchgov:promote' do
    let(:file_path) { File.join(Rails.root.to_s, 'spec', 'fixtures', 'csv', 'searchgov_urls.csv') }
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

    it 'outputs success messages' do
      allow(I14yDocument).to receive(:promote).
        with(handle: 'searchgov', document_id: doc_id, bool: 'true').at_least(:once)
      promote_urls
      expect($stdout.string).to match(%r{Promoted https://www.consumerfinance.gov})
    end

    it 'can demote urls' do
      expect(I14yDocument).to receive(:promote).
        with(handle: 'searchgov', document_id: doc_id, bool: 'false').at_least(:once)
      demote_urls
    end

    it 'indexes new urls' do
      allow(I14yDocument).to receive(:promote).
        with(handle: 'searchgov', document_id: doc_id, bool: 'true').at_least(:once)
      expect { promote_urls }.to change{ SearchgovUrl.count }.by(1)
    end

    it 'creates new urls' do
      expect(I14yDocument).to receive(:create)
      allow(I14yDocument).to receive(:promote).
        with(handle: 'searchgov', document_id: doc_id, bool: 'true').at_least(:once)
      promote_urls
    end

    context 'when something goes wrong' do
      before do
        allow_any_instance_of(SearchgovUrl).to receive(:fetch).and_raise(StandardError)
      end

      it 'logs the failure' do
        promote_urls
        expect($stdout.string).
          to match %r(Failed to promote https://www.consumerfinance.gov/consumer-tools/auto-loans/)
      end
    end
  end

  describe 'searchgov:crawl' do
    let(:task_name) { 'searchgov:crawl' }
    let(:options) { 'search.gov' }
    let(:crawl) do
      @rake[task_name].reenable
      @rake[task_name].invoke(*options)
    end
    let(:crawler) { double(SearchgovCrawler) }

    before do
      allow(SearchgovCrawler).to receive(:new).and_return(crawler)
      crawler.stub_chain(:url_file, :path).and_return('url_file_path')
      crawler.stub(:crawl).and_return(true)
    end

    it 'crawls the domain' do
      expect(SearchgovCrawler).to receive(:new).
        with(domain: 'search.gov', skip_query_strings: false, srsly: false, delay: 0).
        and_return(crawler)
      expect(crawler).to receive(:crawl).and_return(true)
      crawl
    end

    context 'when passing additional options to the task' do
      let(:options) { %w( search.gov srsly skip 5 ) }

      it 'passes the correct options to the crawler' do
        expect(SearchgovCrawler).to receive(:new).
          with(domain: 'search.gov', skip_query_strings: true, srsly: true, delay: 5).
          and_return(crawler)
        crawl
      end
    end

    it 'outputs useful information' do
      crawl
      expect($stdout.string).to match %r{Preparing to crawl search.gov}
    end
  end
end
