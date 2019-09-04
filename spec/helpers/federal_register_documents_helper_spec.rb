require 'spec_helper'

describe FederalRegisterDocumentsHelper do
  let(:document) do
    mock_model(
      FederalRegisterDocument,
      document_type: 'Notice',
      publication_date: 'Mon, 09 Jun 2014'.to_date,
      start_page: 0,
      end_page: 47,
      document_number: '2019-55555',
      contributing_agency_names: ['Internal Revenue Service',
                                  'International Trade Administration',
                                  'National Oceanic and Atmospheric Administration']
    )
  end

  describe '#federal_register_document_info' do
    subject(:federal_register_document_info) do
      helper.federal_register_document_info(document)
    end

    let(:result) do
      <<~HTML.delete!("\n")
        A <span>Notice</span> by the <span>Internal 
        Revenue Service</span>, the <span>International 
        Trade Administration</span> and the <span>National 
        Oceanic and Atmospheric Administration</span> 
        posted on <span>June 9, 2014</span>.
      HTML
    end

    it { is_expected.to eq result }
  end

  describe '#federal_register_document_page_info' do
    subject(:federal_register_document_info) do
      helper.federal_register_document_page_info(document)
    end

    it { is_expected.to eq 'Pages 0 - 47 (0 pages) [FR DOC #: 2019-55555]' }
  end

  describe '#link_to_federal_register_advanced_search' do
    subject(:link_to_federal_register_advanced_search) do
      search.affiliate.agency = Agency.create!({name: 'Some New Agency', abbreviation: 'SNA'})
      helper.link_to_federal_register_advanced_search(search)
    end

    let(:affiliate) {  affiliates(:usagov_affiliate) }
    let(:search) { WebSearch.new(query: 'english', affiliate: affiliate) }
    let(:link) do
      <<~HTML.delete!("\n")
        <a href="https://www.federalregister.gov/articles/search?conditions
        %5Bagency_ids%5D%5B%5D=&amp;conditions%5Bterm%5D=english">More SNA 
        documents on FederalRegister.gov</a>
      HTML
    end

    it { is_expected.to eq link }
  end

  describe '#federal_register_document_comment_period' do
    context 'when the document comments_close_on is before today' do
      before { allow(document).to receive(:comments_close_on).and_return Date.current.prev_week }

      specify { expect(helper.federal_register_document_comment_period(document)).to eq 'Comment Period Closed' }
    end

    context 'when the document comments_close_on is today' do
      before { allow(document).to receive(:comments_close_on).and_return Date.current }

      specify { expect(helper.federal_register_document_comment_period(document)).to eq 'Comment period ends today' }
    end
  end
end
