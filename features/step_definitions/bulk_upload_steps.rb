# frozen_string_literal: true

Then /^there should not be a bulk upload job$/ do
  adapter = ActiveJob::Base.queue_adapter
  enqueued_jobs = adapter.enqueued_jobs

  expect(enqueued_jobs).to be_empty
end

Then /^there should be a bulk upload job$/ do
  adapter = ActiveJob::Base.queue_adapter
  queue_entry = adapter.enqueued_jobs.first
  adapter.enqueued_jobs.clear

  job = queue_entry[:job]

  expect(job).to eq(SearchgovUrlBulkUploaderJob)
end
