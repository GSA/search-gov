require 'spec_helper'

describe DodForm do
  before(:all) { FormAgency.destroy_all }
  let(:rocis_data_path) { "#{Rails.root}/spec/fixtures/csv/forms/rocis_data.csv" }
  let(:dod_form) { DodForm.new(RocisData.new(rocis_data_path).to_hash) }

  describe '#import' do
    let(:forms_page) { File.read("#{Rails.root}/spec/fixtures/html/forms/dod/ddforms.htm") }
    let(:forms_file) { mock(File, :read => forms_page) }

    before do
      dod_form.should_receive(:open).
          with(%r[^http://www.dtic.mil/whs/directives/infomgt/forms/dd/ddforms[[:digit:]]{4}\-[[:digit:]]{4}\.htm$]).
          exactly(6).times.
          and_return(forms_file)

      dod_form.stub(:open) do |arg|
        case arg
        when %r[^http://www.dtic.mil/whs/directives/infomgt/forms/forminfo/forminfopage[[:digit:]]+\.html]
          page_number = arg.slice(/[[:digit:]]+/)
          mock(File, :read => File.read("#{Rails.root}/spec/fixtures/html/forms/dod/forminfopage#{page_number}.html"))
        end
      end
    end

    context 'when there is no exisiting FormAgency' do
      before { dod_form.import }

      it 'should create FormAgency' do
        FormAgency.count.should == 1
        FormAgency.first.name.should == 'defense.gov'
        FormAgency.first.locale.should == 'en'
        FormAgency.first.display_name.should == 'U.S. Department of Defense'
      end
    end

    context 'when there is no existing Form' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'defense.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Department of Defense')
      end

      before { dod_form.import }

      it 'should not create a new FormAgency' do
        FormAgency.count.should == 1
        FormAgency.first.should == form_agency
      end

      it 'should create forms' do
        Form.count.should == 8
      end

      it 'should populate all the available fields' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'DD-3').first
        form.url.should == 'http://www.dtic.mil/whs/directives/infomgt/forms/eforms/dd0003.pdf'
        form.title.should == 'Application for Gold Star Lapel Button'
        form.landing_page_url.should == 'http://www.dtic.mil/whs/directives/infomgt/forms/forminfo/forminfopage1402.html'
        form.file_type.should == 'PDF'
        form.revision_date.should == '2/00'
        form.should be_verified
      end

      it 'should set verified to false for forms without download link' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'DD-1').first
        form.should_not be_verified
        form.links.should be_empty
      end

      it 'should ignore CANCELLED form' do
        Form.where(:form_agency_id => form_agency.id, :number => 'DD2(Act)').should be_empty
      end

      it 'should populate rocis fields' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'DD-149').first
        form.expiration_date.strftime("%m/%d/%y").should == '10/31/14'
        form.abstract.should =~ /\AUnder Title 10/
        form.abstract.should =~ /military records be corrected\.\Z/
        form.line_of_business.should == 'Defense and National Security'
        form.subfunction.should == 'Operational Defense'
        form.public_code.should == 'Individuals or Households'
      end

      it 'should scrape links with HTML format' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'DD-137-3').first
        form.links.count.should == 2

        form.links[0][:title].should == 'Form DD-137-3'
        form.links[0][:url].should == 'http://www.dtic.mil/whs/directives/infomgt/forms/eforms/dd0137-3.pdf'
        form.links[0][:file_type].should == 'PDF'

        form.links[1][:title].should == 'JTFR VOL 1, CH 10'
        form.links[1][:url].should == 'http://www.defensetravel.dod.mil/site/travelreg.cfm'
        form.links[1][:file_type].should == 'HTML'

      end

      it 'should scrape links with FR* format' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'DD-285').first
        form.links.count.should == 4

        form.links[1][:title].should == 'Form DD-285'
        form.links[1][:url].should == 'http://www.dtic.mil/whs/directives/infomgt/forms/eforms/dd0285.frl'
        form.links[1][:file_type].should == 'FRL'

        form.links[2][:title].should == 'Form DD-285'
        form.links[2][:url].should == 'http://www.dtic.mil/whs/directives/infomgt/forms/eforms/dd0285.frz'
        form.links[2][:file_type].should == 'FRZ'
      end

      it 'should scrape links with XLS format' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'DD-2794').first
        form.links.count.should == 2

        form.links[0][:title].should == 'Form DD-2794'
        form.links[0][:url].should == 'http://www.dtic.mil/whs/directives/infomgt/forms/eforms/dd2794.xls'
        form.links[0][:file_type].should == 'XLS'
      end

      it 'should scrape links with custom title' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'DD-2911').first
        form.links.count.should == 4

        form.links[0][:title].should == 'Form DD-2911'
        form.links[0][:url].should == 'http://www.dtic.mil/whs/directives/infomgt/forms/eforms/dd2911.pdf'
        form.links[0][:file_type].should == 'PDF'

        form.links[1][:title].should == 'Instructions for Victim'
        form.links[1][:url].should == 'http://www.dtic.mil/whs/directives/infomgt/forms/eforms/dd2911iv.pdf'
        form.links[1][:file_type].should == 'PDF'

        form.links[2][:title].should == 'Instructions for Suspect'
        form.links[2][:url].should == 'http://www.dtic.mil/whs/directives/infomgt/forms/eforms/dd2911is.pdf'
        form.links[2][:file_type].should == 'PDF'
      end

      it 'should scrape links with DOC format' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'DD-2930').first
        form.links.count.should == 2

        form.links[1][:title].should == 'Form DD-2930'
        form.links[1][:url].should == 'http://www.dtic.mil/whs/directives/infomgt/forms/eforms/dd2930.doc'
        form.links[1][:file_type].should == 'DOC'
      end
    end

    context 'when there is an existing Form with the same agency and number' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'defense.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Department of Defense')
      end

      let!(:existing_form) do
        Form.create! do |f|
          f.form_agency_id = form_agency.id
          f.number = 'DD-3'
          f.url = 'http://www.defense.gov/form.pdf'
          f.file_type = 'DOC'
          f.verified = false
          f.number_of_pages = 100
        end
      end

      before { dod_form.import }

      it 'should create/update forms' do
        Form.where(:form_agency_id => form_agency.id).count.should == 8
      end

      it 'should update existing form' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'DD-3').first
        form.id.should == existing_form.id
        form.url.should == 'http://www.dtic.mil/whs/directives/infomgt/forms/eforms/dd0003.pdf'
        form.title.should == 'Application for Gold Star Lapel Button'
        form.landing_page_url.should == 'http://www.dtic.mil/whs/directives/infomgt/forms/forminfo/forminfopage1402.html'
        form.file_type.should == 'PDF'
        form.revision_date.should == '2/00'
      end

      it 'should reset details fields' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'DD-3').first
        form.number_of_pages.should be_nil
      end

      it 'should not override verified' do
        Form.where(:form_agency_id => form_agency.id, :number => 'DD-3').first.should_not be_verified
      end
    end

    context 'when there is an obsolete Form from the same agency' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'defense.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Department of Defense')
      end

      let!(:obsolete_form) { Form.create!(:form_agency_id => form_agency.id,
                                          :number => 'obsolete',
                                          :url => 'http://www.defense.gov/form.pdf',
                                          :file_type => 'PDF') }

      before { dod_form.import }

      it 'should create forms' do
        Form.where(:form_agency_id => form_agency.id).count.should == 8
      end

      it 'should delete the obsolete form' do
        Form.find_by_id(obsolete_form.id).should be_nil
      end
    end
  end
end
