# frozen_string_literal: true

RSpec.shared_examples 'a bulk upload notification email' do
  it 'has the correct subject' do
    expect(mail.subject).to eq("Bulk URL upload results for #{filename}")
  end

  it 'has the correct recepient' do
    expect(mail.to).to eq([user.email])
  end

  it 'has the correct from header' do
    expect(mail.from).to eq([DELIVER_FROM_EMAIL_ADDRESS])
  end

  it 'has the correct reply-to' do
    expect(mail.reply_to).to eq([SUPPORT_EMAIL_ADDRESS])
  end

  it 'has the correct total number of URLs' do
    expect(mail_body).to match(/There were #{results.total_count} URLs/)
  end
end

RSpec.describe BulkUrlUploadResultsMailer, type: :mailer do
  describe '#results_email' do
    let(:user) { users(:affiliate_admin) }
    let(:filename) { 'test-file.txt' }
    let(:results) do
      results = BulkUrlUploader::Results.new(filename)
      results.add_ok(SearchgovUrl.create(url: 'https://agency.gov/ok-url-1'))
      results.add_ok(SearchgovUrl.create(url: 'https://agency.gov/ok-url-2'))
      results
    end
    let(:mail) do
      described_class.with(user: user, results: results).results_email
    end
    let(:mail_body) { mail.body.encoded }

    describe 'with no errors' do
      it_behaves_like 'a bulk upload notification email'

      it 'reports that there were no URLs with problems' do
        expect(mail_body).to match(/There were no errors/)
      end
    end

    describe 'with errors' do
      let(:already_taken_error_message) { 'Validation failed: Url has already been taken' }
      let(:duplicate_url) { 'https://duplicate.agency.gov' }
      let(:first_error_message) { 'First validation failure' }
      let(:first_bad_url) { 'https://agency.gov/first-bad-url' }
      let(:second_error_message) { 'Second validation failure' }
      let(:second_bad_url) { 'https://agency.gov/second-bad-url' }

      before do
        results.add_error(already_taken_error_message, duplicate_url)
        results.add_error(first_error_message, first_bad_url)
        results.add_error(second_error_message, second_bad_url)
      end

      it_behaves_like 'a bulk upload notification email'

      it 'reports the correct number of OK URLs' do
        expect(mail_body).to match(
          /#{results.ok_count} URLs were created or enqueued successfully/
        )
      end

      it 'reports the correct number of URLs with problems' do
        expect(mail_body).to match(/#{results.error_count} URLs failed validation/)
      end

      it 'shows the first URL validation failure' do
        expect(mail_body).to match(/#{first_error_message}\s+#{first_bad_url}/)
      end

      it 'shows the second URL validation failure' do
        expect(mail_body).to match(/#{second_error_message}\s+#{second_bad_url}/)
      end

      it 'shows the urls with error "url already taken" after all the other errors' do
        first_error_message_position = mail_body.index(first_error_message)
        second_error_message_position = mail_body.index(second_error_message)
        already_taken_error_message_position = mail_body.index(already_taken_error_message)

        expect(already_taken_error_message_position).to be > first_error_message_position
        expect(already_taken_error_message_position).to be > second_error_message_position
      end
    end
  end
end
