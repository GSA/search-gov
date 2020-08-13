# frozen_string_literal: true

Then /^there should not be a bulk upload job$/ do
  the_adapter = ActiveJob::Base.queue_adapter
  enqueued_jobs = the_adapter.enqueued_jobs

  expect(enqueued_jobs).to be_empty
end

Then /^there should be a bulk upload job$/ do
  the_adapter = ActiveJob::Base.queue_adapter
  the_queue_entry = the_adapter.enqueued_jobs.first
  the_adapter.enqueued_jobs.clear

  the_job = the_queue_entry[:job]

  expect(the_job).to eq(SearchgovUrlBulkUploaderJob)
end
