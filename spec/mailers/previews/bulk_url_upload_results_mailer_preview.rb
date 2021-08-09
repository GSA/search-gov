# frozen_string_literal: true

# Preview all emails at http://localhost:3000/rails/mailers
class BulkUrlUploadResultsMailerPreview < ActionMailer::Preview
  def results_email
    user = User.first
    results = BulkUrlUploader::Results.new('the-file.txt')
    results.add_ok(SearchgovUrl.create(url: 'https://ok-url.test'))
    results.add_ok(SearchgovUrl.create(url: 'https://another-ok-url.test'))

    BulkUrlUploadResultsMailer.with(user: user, results: results).results_email
  end

  def results_email_with_errors
    user = User.first
    results = BulkUrlUploader::Results.new('the-file.txt')
    results.add_ok(SearchgovUrl.create(url: 'https://ok-url.test'))
    results.add_error('Url has already been taken', 'https://taken.test')
    results.add_error('one error', 'https://bogus.test')
    results.add_error('one error', 'https://realy-bogus.test')
    results.add_error('another error', 'https://left-field.test')

    BulkUrlUploadResultsMailer.with(user: user, results: results).results_email
  end
end
