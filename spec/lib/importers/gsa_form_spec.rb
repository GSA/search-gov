require 'spec_helper'

describe GsaForm do
  before(:all) { FormAgency.destroy_all }
  let(:rocis_data_path) { "#{Rails.root}/spec/fixtures/csv/forms/rocis_data.csv" }
  let(:gsa_form) { GsaForm.new(RocisData.new(rocis_data_path).to_hash) }

  describe '#import' do
    let!(:gsa_csv) { File.read("#{Rails.root}/spec/fixtures/csv/forms/gsa_forms.csv") }
    let!(:form1_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/gsa/GSA1241.html') }
    let(:form1) { mock(File, :read => form1_landing_page) }
    let!(:form2_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/gsa/GSA1241A.html') }
    let(:form2) { mock(File, :read => form2_landing_page) }
    let!(:form3_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/gsa/GSA1364.html') }
    let(:form3) { mock(File, :read => form3_landing_page) }
    let!(:form4_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/gsa/GSA1656B.html') }
    let(:form4) { mock(File, :read => form4_landing_page) }
    let!(:form5_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/gsa/GPO2511.html') }
    let(:form5) { mock(File, :read => form5_landing_page) }

    before do
      File.should_receive(:read).
          with("#{Rails.root}/tmp/forms/gsa_forms.csv").
          and_return(gsa_csv)
      gsa_form.should_receive(:open).
          with('http://www.gsa.gov/portal/forms/download/113958').
          and_return(form1)
      gsa_form.should_receive(:open).
          with('http://www.gsa.gov/portal/forms/download/113962').
          and_return(form2)
      gsa_form.should_receive(:open).
          with('http://www.gsa.gov/portal/forms/download/113998').
          and_return(form3)
      gsa_form.should_receive(:open).
          with('http://www.gsa.gov/portal/forms/download/114142').
          and_return(form4)
      gsa_form.should_receive(:open).
          with('http://www.gsa.gov/portal/forms/download/114426').
          and_return(form5)
      gsa_form.should_not_receive(:open).
          with('http://www.gsa.gov/portal/forms/download/114718')
    end

    context 'when there is no exisiting FormAgency' do
      before { gsa_form.import }

      it 'should create FormAgency' do
        FormAgency.count.should == 1
        FormAgency.first.name.should == 'gsa.gov'
        FormAgency.first.locale.should == 'en'
        FormAgency.first.display_name.should == 'General Services Administration'
      end
    end

    context 'when there is no existing Form' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'gsa.gov',
                           :locale => 'en',
                           :display_name => 'General Services Administration')
      end

      before { gsa_form.import }

      it 'should not create a new FormAgency' do
        FormAgency.count.should == 1
        FormAgency.first.should == form_agency
      end

      it 'should update FormAgency display name' do
        FormAgency.first.display_name.should == 'General Services Administration'
      end

      it 'should create forms' do
        Form.count.should == 5
      end

      it 'should populate all the available fields' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'GSA1241').first
        form.title.should == 'Contract for Appraisal Report'
        form.landing_page_url.should == 'http://www.gsa.gov/portal/forms/download/113958'
        form.url.should == 'http://www.gsa.gov/portal/getFormFormatPortalData?mediaId=28729'
        form.file_type.should == 'PDF'
        form.file_size.should == '574.3 KB'
        form.revision_date.should == '9/73'
        form.should be_verified
      end

      it 'should populate rocis data' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'GSA1364').first
        form.abstract.should =~ /\AThe GSA Form 1364/
        form.expiration_date.strftime('%-m/%-d/%y').should == '4/30/13'
        form.line_of_business.should == 'Supply Chain Management'
        form.subfunction.should == 'Services Acquisition'
        form.public_code.should == 'Private Sector'
      end

      it 'should populate form links' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'GSA1241A').first
        form.links.count.should == 2
        form.links[0][:title].should == 'Form GSA1241A'
        form.links[0][:url].should == 'http://www.gsa.gov/portal/getFormFormatPortalData?mediaId=28733'
        form.links[0][:file_type].should == 'PDF'
        form.links[0][:file_size].should == '110.5 KB'

        form.links[1][:title].should == 'Form GSA1241A'
        form.links[1][:url].should == 'http://www.gsa.gov/portal/getFormFormatPortalData?mediaId=32281'
        form.links[1][:file_type].should == 'DOC'
        form.links[1][:file_size].should be_blank
      end

      it 'should hide form without download link' do
        Form.where(:form_agency_id => form_agency.id, :number => 'GSA1656B').first.should_not be_verified
      end

      it 'should create form with blank revision date' do
        Form.where(:form_agency_id => form_agency.id, :number => 'GPO2511').should_not be_empty
      end

      it 'should skip form with obsolete revision date' do
        Form.where(:form_agency_id => form_agency.id, :number => 'GSA3076C').should be_empty
      end
    end

    context 'when there is existing Form with the same agency and number' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'gsa.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Social Security Administration')
      end

      let!(:existing_form) do
        Form.create! do |f|
          f.form_agency_id = form_agency.id
          f.number = 'GSA1241'
          f.title = 'Contract for Appraisal Report'
          f.url = 'http://www.gsa.gov/form.pdf'
          f.file_type = 'PDF'
          f.verified = false
          f.number_of_pages = 100
        end
      end

      before { gsa_form.import }

      it 'should create/update forms' do
        Form.where(:form_agency_id => form_agency.id).count.should == 5
      end

      it 'should update existing form' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'GSA1241').first
        form.id.should == existing_form.id
        form.title.should == 'Contract for Appraisal Report'
        form.landing_page_url.should == 'http://www.gsa.gov/portal/forms/download/113958'
        form.url.should == 'http://www.gsa.gov/portal/getFormFormatPortalData?mediaId=28729'
        form.file_type.should == 'PDF'
        form.file_size.should == '574.3 KB'
        form.revision_date.should == '9/73'
      end

      it 'should reset details fields' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'GSA1241').first
        form.number_of_pages.should be_nil
      end

      it 'should not override verified' do
        Form.where(:form_agency_id => form_agency.id, :number => 'GSA1241').first.should_not be_verified
      end
    end

    context 'when there is an obsolete Form from the same agency' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'gsa.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Social Security Administration')
      end

      let!(:obsolete_form) { Form.create!(:form_agency_id => form_agency.id,
                                          :number => 'obsolete',
                                          :title => 'title of an obsolete form',
                                          :url => 'http://www.gsa.gov/form.pdf',
                                          :file_type => 'PDF') }

      before { gsa_form.import }

      it 'should create forms' do
        Form.where(:form_agency_id => form_agency.id).count.should == 5
      end

      it 'should delete the obsolete form' do
        Form.find_by_id(obsolete_form.id).should be_nil
      end
    end
  end

  describe '#parse_landing_page' do
    let(:landing_page_url) { 'http://www.gsa.gov/portal/forms/download/113958'.freeze }
    let!(:form1_landing_page) { File.read(Rails.root.to_s + '/spec/fixtures/html/forms/gsa/GSA1241.html') }
    let(:form1) { mock(File, :read => form1_landing_page) }

    context 'when there is an error while parse landing page' do
      before do
        gsa_form.should_receive(:open).with(landing_page_url).and_raise
        gsa_form.should_receive(:open).with(landing_page_url).and_return(form1)
        Rails.logger.should_not_receive(:warn)
      end

      it 'should return Nokogiri HTML document' do
        gsa_form.parse_landing_page(landing_page_url).should be_kind_of(Nokogiri::HTML::Document)
      end
    end

    context 'when all attempts to parse landing page failed' do
      before do
        gsa_form.stub(:open).with(landing_page_url).and_raise
        Rails.logger.should_receive(:warn)
      end

      specify { lambda { gsa_form.parse_landing_page(landing_page_url) }.should raise_error }
    end
  end
end
