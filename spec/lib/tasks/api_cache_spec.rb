require 'spec_helper'
require 'rake'

describe 'ApiCache rake tasks' do
  before(:all) do
    Rake.application.rake_require('tasks/api_cache')
    Rake::Task.define_task(:environment)
  end

  describe 'usasearch:api_cache:cleanup' do
    subject(:cleanup) do
      Rake::Task['usasearch:api_cache:cleanup'].reenable
      Rake::Task['usasearch:api_cache:cleanup'].invoke
    end

    let(:cleanup_command) { 'find /file/store/root/* -depth -cmin +1440 -exec rm -r {} \;' }
    let(:cleanup_result) { true }

    before do
      ApiCache.stub(:file_store_root).and_return('/file/store/root')
      Dir.stub(:[]).with('/file/store/root/*').and_return([:some, :files])
      Kernel.stub(:system).with(cleanup_command).and_return(cleanup_result)
    end

    context 'when no MAX_AGE_MINUTES environment variable is specified' do
      it 'should execute a system command to delete cache entry files older than the default number of minutes' do
        cleanup
      end
    end

    context 'when a MAX_AGE_MINUTES environment variable is specified' do
      let(:cleanup_command) { 'find /file/store/root/* -depth -cmin +42 -exec rm -r {} \;' }

      before do
        @prevous_max_age_minutes = ENV['MAX_AGE_MINUTES']
        ENV['MAX_AGE_MINUTES'] = '42'
      end

      after do
        ENV['MAX_AGE_MINUTES'] = @prevous_max_age_minutes
      end

      it 'should execute a system command to delete cache entry files older than that many minutes' do
        cleanup
      end
    end

    context 'when the executed system command fails' do
      let(:cleanup_result) { false }

      it 'raises a runtime error' do
        expect { cleanup }.to raise_error(RuntimeError, 'could not flush old api_cache entries')
      end
    end
  end
end
