require 'spec_helper'

describe 'admin/bulk_affiliate_delete/index.html.haml', type: :view do
  let(:page_title) { 'Bulk Affiliate Delete Test Title' }

  before do
    assign(:page_title, page_title)
    render
  end

  it 'displays the page title' do
    expect(rendered).to have_selector('h2', text: page_title)
  end

  it 'displays the instructions paragraph' do
    expect(rendered).to have_selector('p', text: /To bulk delete affiliates using a CSV file/)
  end

  it 'displays the instructions list' do
    expect(rendered).to have_selector('ul.bulk-upload-instructions')
    expect(rendered).to have_selector('ul.bulk-upload-instructions li', minimum: 8) # Check for at least 8 instruction points
    expect(rendered).to have_selector('ul.bulk-upload-instructions li', text: /Create a plain text file with a \.csv extension/)
    expect(rendered).to have_selector('ul.bulk-upload-instructions li', text: /List one Affiliate ID per row/)
    expect(rendered).to have_selector('ul.bulk-upload-instructions li', text: /Click "Upload and Queue Deletion"/)
  end

  it 'displays the example textarea' do
    expect(rendered).to have_selector('textarea[readonly]', text: "123\n456\n789")
  end

  it 'renders the upload form' do
    expect(rendered).to have_selector("form[action='#{upload_admin_bulk_affiliate_delete_index_path}'][method='post'][enctype='multipart/form-data']")
  end

  it 'renders the file input field' do
    expect(rendered).to have_selector('label.usa-label[for="file"]', text: 'Select CSV file of Affiliate IDs:')
    expect(rendered).to have_selector('input.usa-file-input[type="file"][name="file"][required="required"][accept=".csv"]')
  end

  it 'renders the submit button' do
    expect(rendered).to have_button('Upload and Queue Deletion', class: 'usa-button usa-button--secondary')
  end
end
