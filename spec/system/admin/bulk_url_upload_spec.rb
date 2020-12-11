# frozen_string_literal: true

describe 'Bulk URL upload' do
  include ActiveJob::TestHelper

  subject(:bulk_upload) do
    perform_enqueued_jobs do
      visit url
      attach_file('bulk_upload_urls', url_file)
      click_button('Upload')
    end
  end

  let(:url) { '/admin/bulk_url_upload' }
  let(:url_filedir) { 'txt' }
  let(:url_filename) { 'good_url_file.txt' }
  let(:url_file) { file_fixture("#{url_filedir}/#{url_filename}") }
  let(:urls) { File.open(url_file).readlines.map(&:strip) }
  let(:searchgov_domains) do
    urls.reduce(Set.new) do |searchgov_domains, raw_url|
      parsed_url = URI(raw_url)
      domain = parsed_url.host
      searchgov_domain = SearchgovDomain.find_by(domain: domain)
      searchgov_domains << searchgov_domain if searchgov_domain
    end
  end

  before do
    @reindexed_domains = Set.new
    allow_any_instance_of(SearchgovDomain).to receive(:index_urls) do |searchgov_domain|
      @reindexed_domains << searchgov_domain
    end
  end

  it_behaves_like 'a page restricted to super admins'

  describe 'bulk uploading a file of URLs' do
    include_context 'log in super admin'

    it 'sends us back to the bulk upload page' do
      bulk_upload
      expect(page).to have_text('Bulk Search.gov URL Upload')
    end

    it 'shows a confirmation message' do
      bulk_upload
      expect(page).to have_text(
        <<~CONFIRMATION_MESSAGE
          Successfully uploaded #{url_filename} for processing.
          The results will be emailed to you.
        CONFIRMATION_MESSAGE
      )
    end

    it 'creates the URLs' do
      bulk_upload
      urls.each do |url|
        expect(SearchgovUrl.find_by(url: url)).not_to be_blank
      end
    end

    it 're-indexes the domains for the URLs' do
      bulk_upload
      expect(@reindexed_domains).to eq(searchgov_domains)
    end
  end

  describe 'trying to bulk upload a file of URLs when there is no file attached' do
    include_context 'log in super admin'

    subject(:bulk_upload) do
      visit url
      click_button('Upload')
    end

    it 'sends us back to the bulk upload page' do
      bulk_upload
      expect(page).to have_text('Bulk Search.gov URL Upload')
    end

    it 'shows an error message' do
      bulk_upload
      expect(page).to have_text(
        <<~ERROR_MESSAGE
          Please choose a file to upload.
        ERROR_MESSAGE
      )
    end
  end

  describe 'trying to bulk upload a file of URLs that is not a text file' do
    include_context 'log in super admin'

    let(:url_file) { file_fixture('word/bogus_url_file.docx') }

    it 'sends us back to the bulk upload page' do
      bulk_upload
      expect(page).to have_text('Bulk Search.gov URL Upload')
    end

    it 'shows an error message' do
      bulk_upload
      expect(page).to have_text(
        <<~ERROR_MESSAGE
          Files of type application/vnd.openxmlformats-officedocument.wordprocessingml.document are not supported
        ERROR_MESSAGE
      )
    end
  end

  describe 'trying to bulk upload a file of URLs that is too big' do
    include_context 'log in super admin'

    let(:url_filename) { 'too_big_url_file.txt' }

    it 'sends us back to the bulk upload page' do
      bulk_upload
      expect(page).to have_text('Bulk Search.gov URL Upload')
    end

    it 'shows an error message' do
      bulk_upload
      expect(page).to have_text(
        <<~ERROR_MESSAGE
          #{url_filename} is too big; please split it.
        ERROR_MESSAGE
      )
    end
  end
end
