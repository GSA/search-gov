# frozen_string_literal: true

shared_examples 'a failed bulk upload with error' do |error_message|
  it 'sends us back to the bulk upload page' do
    do_bulk_upload
    expect(page).to have_text('Bulk Search.gov URL Upload')
  end

  it 'shows an error message' do
    do_bulk_upload
    expect(page).to have_text(error_message)
  end
end

describe 'Bulk URL upload' do
  include ActiveJob::TestHelper

  subject(:do_bulk_upload) do
    perform_enqueued_jobs do
      visit url
      attach_file('bulk_upload_urls', upload_file)
      click_button('Upload')
    end
  end

  let(:url) { '/admin/bulk_url_upload' }
  let(:upload_file) { file_fixture("txt/#{upload_filename}") }
  let(:urls) { File.open(upload_file).readlines.map(&:strip) }
  let(:searchgov_domain) { searchgov_domains(:agency_gov) }

  before { allow(searchgov_domain).to receive(:index_urls) }

  it_behaves_like 'a page restricted to super admins'

  context 'when a super admin is logged in' do
    include_context 'log in super admin'

    describe 'bulk uploading a file of URLs' do
      let(:upload_filename) { 'good_url_file.txt' }

      it 'sends us back to the bulk upload page' do
        do_bulk_upload
        expect(page).to have_text('Bulk Search.gov URL Upload')
      end

      it 'shows a confirmation message' do
        do_bulk_upload
        expect(page).to have_text(
          "Successfully uploaded #{upload_filename} for processing. The results will be emailed to you."
        )
      end

      it 'creates the URLs' do
        do_bulk_upload

        urls.each do |url|
          expect(SearchgovUrl.find_by(url: url)).not_to be_blank
        end
      end

      it 're-indexes the domains for the URLs' do
        reindexed_domains = Set.new
        allow_any_instance_of(SearchgovDomain).to receive(:index_urls) do |searchgov_domain|
          reindexed_domains << searchgov_domain
        end
        do_bulk_upload
        expect(reindexed_domains).to eq(Set[searchgov_domain])
      end
    end

    context 'when the URLs contain non-ASCII characters' do
      let(:upload_filename) { 'non_ascii_urls.txt' }

      it 'saves the encoded URLs' do
        do_bulk_upload

        expect(SearchgovUrl.pluck(:url)).to include(
          'https://agency.gov/foo%20%C2%A7%20208.pdf?open',
          'https://agency.gov/Asesor%E2%88%9A%E2%89%A0a.pdf'
        )
      end
    end

    describe 'trying to bulk upload a file of URLs when there is no file attached' do
      let(:upload_file) { nil }

      it_behaves_like 'a failed bulk upload with error', 'Please choose a file to upload'
    end

    describe 'trying to bulk upload a file of URLs that is not a text file' do
      let(:upload_filename) { 'bogus_url_file.docx' }
      let(:upload_file) { file_fixture('word/bogus_url_file.docx') }

      it_behaves_like 'a failed bulk upload with error',
                      'Files of type application/vnd.openxmlformats-officedocument.wordprocessingml.document are not supported'
    end

    describe 'trying to bulk upload a file of URLs that is too big' do
      let(:upload_filename) { 'too_big_url_file.txt' }

      it_behaves_like 'a failed bulk upload with error', 'too_big_url_file.txt is too big; please split it'
    end
  end
end
