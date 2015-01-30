require 'spec_helper'

describe FederalRegisterDocumentApiParser do
  fixtures :agencies, :federal_register_agencies

  describe '#each_document' do
    let(:fr_agency) { federal_register_agencies(:fr_irs) }
    let(:parser) { parser = FederalRegisterDocumentApiParser.new(federal_register_agency_ids: [fr_agency.id]) }
    let(:results) { mock('results', next: nil) }

    before { FederalRegister::Article.should_receive(:search).and_return(results) }

    it 'extracts boolean fields' do
      significant = true

      unsanitized_document_1 = mock('document',
                                    attributes: { 'agencies' => [{ 'id' => fr_agency.id }],
                                                  'significant' => significant })
      results.should_receive(:each).and_yield(unsanitized_document_1)

      parser.each_document do |document|
        document[:significant].should be_true
      end
    end

    it 'extracts number fields' do
      end_page, page_length, start_page = 800, 2, 799
      unsanitized_document_1 = mock('document',
                                    attributes: { 'agencies' => [{ 'id' => fr_agency.id }],
                                                  'end_page' => end_page,
                                                  'page_length' => page_length,
                                                  'start_page' => start_page })
      results.should_receive(:each).and_yield(unsanitized_document_1)

      parser.each_document do |document|
        document[:end_page].should eq end_page
        document[:page_length].should eq page_length
        document[:start_page].should eq start_page
      end
    end

    it 'parses date fields' do
      comments_close_on_str = '2020-08-08'.freeze
      effective_on_str = '2014-06-01'.freeze
      publication_date_str = '2014-01-01'.freeze
      unsanitized_document_1 = mock('document',
                                    attributes: { 'agencies' => [{ 'id' => fr_agency.id }],
                                                  'comments_close_on' => comments_close_on_str,
                                                  'effective_on' => effective_on_str,
                                                  'publication_date' => publication_date_str })
      results.should_receive(:each).and_yield(unsanitized_document_1)

      parser.each_document do |document|
        document[:comments_close_on].should eq(Date.parse comments_close_on_str)
        document[:effective_on].should eq(Date.parse effective_on_str)
        document[:publication_date].should eq(Date.parse publication_date_str)
      end
    end

    it 'squishes string fields' do
      abstract = 'arbitrary   abstract with   spaces'.freeze
      docket_id = '  File No.   500-1  '
      document_number = ' 1111-3333 '.freeze
      html_url = ' http://www.federalregister.gov/doc.html  '
      title = 'arbitrary   title with   spaces'.freeze
      type = ' Notice '
      unsanitized_document_1 = mock('document',
                                    attributes: { 'abstract' => abstract,
                                                  'agencies' => [{ 'id' => fr_agency.id }],
                                                  'docket_id' => docket_id,
                                                  'document_number' => document_number,
                                                  'html_url' => html_url,
                                                  'title' => title,
                                                  'type' => type })
      results.should_receive(:each).and_yield(unsanitized_document_1)

      parser.each_document do |document|
        document[:abstract].should eq 'arbitrary abstract with spaces'
        document[:docket_id].should eq 'File No. 500-1'
        document[:document_number].should eq '1111-3333'
        document[:html_url].should eq 'http://www.federalregister.gov/doc.html'
        document[:title].should eq 'arbitrary title with spaces'
        document[:document_type].should eq 'Notice'
      end
    end

    it 'extracts federal register agency ids' do
      document_number = ' 1111-3333 '.freeze
      title = 'arbitrary   title with   spaces'.freeze
      unsanitized_document_1 = mock('document',
                                    attributes: { 'agencies' => [{ 'id' => 492 },
                                                                 { 'id' => 159 },
                                                                 { 'id' => 159, 'raw_name' => 'duplicate agency ID' },
                                                                 { 'raw_name' => 'agency without ID' }],
                                                  'document_number' => document_number,
                                                  'title' => title })
      results.should_receive(:each).and_yield(unsanitized_document_1)

      parser.each_document do |document|
        document[:federal_register_agency_ids].should eq [159, 492]
      end
    end
  end

end
