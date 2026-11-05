require 'spec_helper'

describe 'sites/visual_designs/edit' do
  fixtures :affiliates, :users
  let(:site) { affiliates(:basic_affiliate) }

  before do
    activate_authlogic
    assign :site, site
    affiliate_user = users(:affiliate_manager)
    UserSession.create(affiliate_user)
    allow(view).to receive(:current_user).and_return affiliate_user
    allow(view).to receive(:site_visual_design_path).and_return("/sites/#{site.id}/visual_design")
  end

  it 'hides the Results Format tab and section' do
    render

    expect(rendered).not_to include('Results Format')
    expect(rendered).not_to include('results_format')
    expect(rendered).not_to include('Display image on search results')
    expect(rendered).not_to include('Display filetype on search results')
    expect(rendered).not_to include('Display created date on search results')
    expect(rendered).not_to include('Display updated date on search results')
  end

  it 'still shows the other visual design tabs' do
    render

    expect(rendered).to include('Fonts &amp; Colors')
    expect(rendered).to include('Image Assets')
    expect(rendered).to include('Header &amp; Footer')
  end
end
