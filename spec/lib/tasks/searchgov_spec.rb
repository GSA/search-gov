require 'spec_helper'

describe 'Search.gov tasks' do
  before(:all) do
    @rake = Rake::Application.new
    Rake.application = @rake
    Rake.application.rake_require('tasks/searchgov')
    Rake::Task.define_task(:environment)
  end

  before { $stdout = StringIO.new }
  after { $stdout = STDOUT }

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
