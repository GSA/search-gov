# coding: utf-8
require 'spec_helper'

describe UscisForm do
  before(:all) { FormAgency.destroy_all }
  let(:rocis_data_path) { "#{Rails.root}/spec/fixtures/csv/forms/rocis_data.csv" }
  let(:uscis_form) { UscisForm.new(RocisData.new(rocis_data_path).to_hash) }

  describe '#import' do
    let(:forms_index_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/forms.html') }
    let(:forms_index_url) { 'http://www.uscis.gov/vgn-ext-templating/v/index.jsp?vgnextoid=db0' }
    let(:forms_file) { mock(File, :read => forms_index_page)}
    let(:form1_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/form1.html') }
    let(:form1) { mock(File, :read => form1_landing_page) }
    let(:form2_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/form2.html') }
    let(:form2) { mock(File, :read => form2_landing_page) }
    let(:form3_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/form3.html') }
    let(:form3) { mock(File, :read => form3_landing_page) }
    let(:form4_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/form4.html') }
    let(:form4) { mock(File, :read => form4_landing_page) }
    let(:form5_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/form5.html') }
    let(:form5) { mock(File, :read => form5_landing_page) }
    let(:instruction1_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/instruction1.html') }
    let(:instruction1) { mock(File, :read => instruction1_landing_page) }
    let(:instruction2_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/instruction2.html') }
    let(:instruction2) { mock(File, :read => instruction2_landing_page) }

    before do
      uscis_form.should_receive(:retrieve_forms_index_url).and_return(forms_index_url)
      uscis_form.should_receive(:open).with(forms_index_url).and_return(forms_file)
      uscis_form.should_receive(:open).
          with(%r[^http://www.uscis.gov/portal/site/uscis/menuitem.5af9bb95919f35e66f614176543f6d1a]).
          exactly(5).times.
          and_return(form1, form2, instruction1, form3, instruction2, form4, form5)
    end

    context 'when there is no exisiting FormAgency' do
      before { uscis_form.import }

      it 'should create FormAgency' do
        FormAgency.count.should == 1
        FormAgency.first.name.should == 'uscis.gov'
        FormAgency.first.locale.should == 'en'
        FormAgency.first.display_name.should == 'U.S. Citizenship and Immigration Services'
      end
    end

    context 'when there is no existing Form' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'uscis.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Citizenship and Immigration Services')
      end

      before { uscis_form.import }

      it 'should not create a new FormAgency' do
        FormAgency.count.should == 1
        FormAgency.first.should == form_agency
      end

      it 'should update FormAgency display name' do
        FormAgency.first.display_name.should == 'U.S. Citizenship and Immigration Services'
      end

      it 'should create forms' do
        Form.count.should == 7
      end

      it 'should populate all the available fields' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'AR-11').first
        form.url.should == 'http://www.uscis.gov/files/form/ar-11.pdf'
        form.title.should == 'Change of Address'
        form.description.should =~ /\ATo report the change of address of an alien in the United States/
        form.landing_page_url.should == 'http://www.uscis.gov/ar-11'
        form.file_size.should == '370KB'
        form.file_type.should == 'PDF'
        form.number_of_pages.should == '1'
        form.revision_date.should == '12/11/11'
        form.expiration_date.strftime("%m/%d/%y").should == '12/31/14'
        form.should be_govbox_enabled
      end

      it 'should populate form links' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'I-129F').first
        form.links[1][:title].should == 'Instructions for Form I-129F'
        form.links[1][:url].should == 'http://www.uscis.gov/files/form/i-129finstr.pdf'
        form.links[1][:file_size].should == '219KB'
        form.links[1][:file_type].should == 'PDF'
        form.links[2][:title].should == 'Form G-1145, Notification of Acceptance of Application/Petition'
        form.links[2][:url].should == 'http://www.uscis.gov/files/form/g-1145.pdf'
        form.links[2][:file_size].should == '1KB'
        form.links[2][:file_type].should == 'PDF'
      end

      it 'should handle latin characters' do
        Form.where(:form_agency_id => form_agency.id, :number => 'I-129F').first.title.should == 'Petition for Alien Fiancé(e)'
      end

      it 'should handle %b %Y revision date' do
        Form.where(:form_agency_id => form_agency.id, :number => 'EOIR-29').first.revision_date.should == '4/09'
      end

      it 'should handle number of pages in instruction form' do
        Form.where(:form_agency_id => form_agency.id, :number => 'I-539, Supplement A').first.number_of_pages.should == '2'
      end

      it 'should handle %mm/%yy revision date' do
        Form.where(:form_agency_id => form_agency.id, :number => 'I-193').first.revision_date.should == '12/10'
      end

      it 'should set govbox_enabled to false for forms that are not published by USCIS' do
        Form.where(:form_agency_id => form_agency.id, :number => 'EOIR-29').first.should_not be_govbox_enabled
        Form.where(:form_agency_id => form_agency.id, :number => 'I-193').first.should_not be_govbox_enabled
      end

      it 'should set govbox_enabled to true for forms that does not exist in ROCIS' do
        Form.where(:form_agency_id => form_agency.id, :number => 'I-800A').first.should be_govbox_enabled
      end

      it 'should locate short URL for form I-800A' do
        Form.where(:form_agency_id => form_agency.id, :number => 'I-800A').first.landing_page_url.should == 'http://www.uscis.gov/i-800a'
      end
    end

    context 'when there is existing Form with the same agency and number' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'uscis.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Citizenship and Immigration Services')
      end

      let!(:existing_form) { Form.create!(:form_agency_id => form_agency.id,
                                          :number => 'AR-11',
                                          :url => 'http://www.uscis.gov/form.pdf',
                                          :file_type => 'PDF',
                                          :govbox_enabled => false) }

      before { uscis_form.import }

      it 'should create/update forms' do
        Form.where(:form_agency_id => form_agency.id).count.should == 7
      end

      it 'should update existing form' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'AR-11').first
        form.id.should == existing_form.id
      end

      it 'should not override govbox_enabled' do
        Form.where(:form_agency_id => form_agency.id, :number => 'AR-11').first.should_not be_govbox_enabled
      end
    end

    context 'when there is an obsolete Form from the same agency' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'uscis.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Citizenship and Immigration Services')
      end

      let!(:obsolete_form) { Form.create!(:form_agency_id => form_agency.id,
                                          :number => 'obsolete',
                                          :url => 'http://www.uscis.gov/form.pdf',
                                          :file_type => 'PDF') }

      before { uscis_form.import }

      it 'should create forms' do
        Form.where(:form_agency_id => form_agency.id).count.should == 7
      end

      it 'should delete the obsolete form' do
        Form.find_by_id(obsolete_form.id).should be_nil
      end
    end

    context 'when there is a matching usagov FAQs IndexedDocuments' do
      fixtures :affiliates

      let!(:form_agency) do
        FormAgency.create!(:name => 'uscis.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Citizenship and Immigration Services')
      end

      let(:usagov) { affiliates(:usagov_affiliate) }

      let!(:faqs) do
        SiteDomain.create!(:affiliate_id => usagov.id, :domain => 'usa.gov')
        DocumentCollection.create!(
            :affiliate_id => usagov.id,
            :name => 'FAQs',
            :url_prefixes_attributes => { '0' => { :prefix => 'http://answers.usa.gov/' }})
      end

      let!(:indexed_document1) do
        IndexedDocument.create!(:affiliate_id => usagov.id,
                                :title => 'some docs about form AR-11',
                                :description => 'some title about form AR-11',
                                :url => 'http://answers.usa.gov/page1.html',
                                :doctype => 'html',
                                :last_crawl_status => IndexedDocument::OK_STATUS)
      end

      let!(:indexed_document2) do
        IndexedDocument.create!(:affiliate_id => usagov.id,
                                :title => 'another docs about form AR-11',
                                :description => 'another title about form AR-11',
                                :url => 'http://answers.usa.gov/page2.html',
                                :doctype => 'html',
                                :last_crawl_status => IndexedDocument::OK_STATUS)
      end

      let(:dc) { mock('dc', :count => 1, :first => faqs) }
      let(:odies) { mock('odies', :results => [indexed_document1, indexed_document2])}

      before do
        IndexedDocument.reindex
        uscis_form.import
      end

      it 'should create FormsIndexedDocuments' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'AR-11').first
        form.indexed_documents.count.should == 2
        form.indexed_documents.should include indexed_document1
        form.indexed_documents.should include indexed_document2
      end
    end
  end

  describe '#retrieve_forms_index_url' do
    let(:forms_index_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/uscis/forms.html') }
    let(:forms_index_url) { 'http://www.uscis.gov/vgn-ext-templating/v/index.jsp?vgnextoid=db0' }

    it 'should return form_index_url' do
      uscis_form.should_receive(:open).
          with('http://www.uscis.gov/portal/site/uscis').
          and_return(forms_index_page)
      uscis_form.retrieve_forms_index_url.should == forms_index_url
    end
  end
end
