require 'spec_helper'

describe FederalRegisterDocumentsHelper do
  describe '#federal_register_document_info' do
    subject(:federal_register_document_info) do
      helper.federal_register_document_info(document)
    end

    let(:document) do
      mock_model(
        FederalRegisterDocument,
        document_type: 'Notice',
        publication_date: 'Mon, 09 Jun 2014'.to_date,
        contributing_agency_names: ['Internal Revenue Service',
                                    'International Trade Administration',
                                    'National Oceanic and Atmospheric Administration']
      )
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

  describe 'federal register links' do
    subject(:federal_register_document_info) do
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
    let(:document) do
      mock_model(
        FederalRegisterDocument,
        document_type: "Notice",
        publication_date: "Mon, 09 Jun 2014".to_date,
        contributing_agency_names: ['Internal Revenue Service',
                                    'International Trade Administration',
                                    'National Oceanic and Atmospheric Administration']
      )
    end

    context 'when federal_register_document_info is called' do
      let(:result) do
        "A <span>Notice</span> by the <span>Internal " \
        "Revenue Service</span>, the <span>International " \
        "Trade Administration</span> and the <span>National " \
        "Oceanic and Atmospheric Administration</span> " \
        "posted on <span>June 9, 2014</span>."
      end

      specify { expect(helper.federal_register_document_info(document)).to eq result }
    end

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
