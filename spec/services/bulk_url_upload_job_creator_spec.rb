# frozen_string_literal: true

describe BulkUrlUploadJobCreator do
  describe '#create_job!' do
    include ActionDispatch::TestProcess::FixtureFile

    let(:a_user) { users(:affiliate_admin) }

    let(:job_creator) { described_class.new(uploaded_file, a_user) }
    let(:job) { job_creator.create_job! }

    let(:file_name) { nil }
    let(:file_type) { 'text/plain' }
    let(:uploaded_file) { fixture_file_upload(file_name, file_type) }

    before { ActiveJob::Base.queue_adapter = :test }

    describe 'with a good url file' do
      let(:file_name) { 'txt/good_url_file.txt' }

      it 'queues a job' do
        expect { job }.to have_enqueued_job.with(a_user, job_creator.redis_key)
      end
    end

    describe 'with a url file that is too big' do
      let(:file_name) { 'txt/too_big_url_file.txt' }

      it 'raises an exception' do
        expect { job }.to raise_error(BulkUrlUploader::Error)
      end

      it 'does not queue a job' do
        expect do
          job
        rescue BulkUrlUploader::Error
        end.not_to have_enqueued_job
      end
    end

    describe 'with a url file that is the wrong mime type' do
      let(:file_name) { 'word/bogus_url_file.docx' }
      let(:file_type) { 'application/vnd.openxmlformats-officedocument.wordprocessingml.document' }

      it 'raises an exception' do
        expect { job }.to raise_error(BulkUrlUploader::Error)
      end

      it 'does not queue a job' do
        expect do
          job
        rescue BulkUrlUploader::Error
        end.not_to have_enqueued_job
      end
    end
  end
end
