require 'spec_helper'

describe VaForm do
  before(:all) { FormAgency.destroy_all }
  let(:rocis_data_path) { "#{Rails.root}/spec/fixtures/csv/forms/rocis_data.csv" }
  let(:va_form) { VaForm.new(RocisData.new(rocis_data_path).to_hash) }

  describe '#form_index_page_urls' do
    subject(:urls) { va_form.form_index_page_urls.flatten }

    its(:count) { should == 11 }
    its(:first) { should == VaForm::FORMS_HOME_PAGE_URL }

    it 'should include http://www.va.gov/vaforms/Default.asp?CurrentPage=[2-11]&orderby=' do
      urls.slice(1, 10).each { |u| u.should =~ %r{^http://www.va.gov/vaforms/Default.asp\?CurrentPage=([2-9]|1[0-1])&orderby=$} }
    end
  end

  describe '#import' do
    let(:index_page_urls) { %w(http://www.va.gov/vaforms/ http://www.va.gov/vaforms/Default.asp?CurrentPage=2&orderby=) }
    before do
      va_form.should_receive(:form_index_page_urls).and_return(index_page_urls)
      va_form.stub(:open) do |url|
        case url
        when 'http://www.va.gov/vaforms/'
          mock(File, :read => File.read("#{Rails.root}/spec/fixtures/html/forms/va/forms.html"))
        when %r{^http://www.va.gov/vaforms/Default.asp\?CurrentPage=([2-9]|1[0-1])&orderby=$}
          mock(File, :read => File.read("#{Rails.root}/spec/fixtures/html/forms/va/forms.html"))
        when %r{^http://www.va.gov/vaforms/form_detail.asp\?FormNo=.+}i
          form_no = url.split('=', 2)[1]
          mock(File, :read => File.read("#{Rails.root}/spec/fixtures/html/forms/va/#{form_no}.html"))
        end
      end
    end

    context 'when there is no exisiting FormAgency' do
      before { va_form.import }

      it 'should create FormAgency' do
        FormAgency.count.should == 1
        FormAgency.first.name.should == 'va.gov'
        FormAgency.first.locale.should == 'en'
        FormAgency.first.display_name.should == 'Department of Veterans Affairs'
      end
    end

    context 'when there is no existing Form' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'va.gov',
                           :locale => 'en',
                           :display_name => 'Department of Veterans Affairs')
      end

      before { va_form.import }

      it 'should not create a new FormAgency' do
        FormAgency.count.should == 1
        FormAgency.first.should == form_agency
      end

      it 'should create forms' do
        Form.count.should == 6
      end

      it 'should populate all the available fields' do
        form = Form.where(:form_agency_id => form_agency.id, :number => '10-0137').first
        form.url.should == 'http://www.va.gov/vaforms/medical/pdf/vha-10-0137-fill.pdf'
        form.title.should == 'VA Advance Directive: Living Will & Durable Power of Attorney for Health Care'
        form.landing_page_url.should == 'http://www.va.gov/vaforms/form_detail.asp?FormNo=0137'
        form.file_type.should == 'PDF'
        form.revision_date.should == '3/11'
        form.number_of_pages.should == '7'
        form.should be_verified
      end

      it 'should set verified to false for forms without download link' do
        form = Form.where(:form_agency_id => form_agency.id, :number => '10-0094A').first
        form.links.should be_empty
        form.should_not be_verified
      end

      it 'should populate rocis fields' do
        form = Form.where(:form_agency_id => form_agency.id, :number => '10-0137').first
        form.expiration_date.strftime("%-m/%d/%y").should == '8/31/14'
        form.abstract.should =~ /^The form allows VA/
        form.abstract.should =~ / verbally express these instructions\.$/
        form.line_of_business.should == 'Health'
        form.subfunction.should == 'Health Care Services'
        form.public_code.should == 'Individuals or Households'
      end

      it 'should normalize form number' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'FL-10-341A').first
        form.revision_date.should == '7/06'
        form.expiration_date.strftime("%-m/%d/%y").should == '8/31/15'

        Form.where(:form_agency_id => form_agency.id, :number => 'FL-29-459').should be_present
      end

      it 'should skip duplicate forms' do
        Form.where(:form_agency_id => form_agency.id, :number => '10-1010EZ').should be_empty
      end

      it 'should add links' do
        form = Form.where(:form_agency_id => form_agency.id, :number => '10-10EZ').first
        form.links[0][:title].should == 'Form 10-10EZ'
        form.links[0][:url].should == 'http://www.va.gov/vaforms/medical/pdf/vha-10-10EZ-fill.pdf'
        form.links[0][:file_type].should == 'PDF'
        form.links[0][:number_of_pages].should == '6'

        form.links[1][:title].should == 'Instruction for 10-10EZ'
        form.links[1][:url].should == 'https://www.1010ez.med.va.gov/sec/vha/1010ez/'
        form.links[1][:file_type].should == 'HTML'
        form.links[1][:number_of_pages].should be_nil
      end

      it 'should skip GSA forms' do
        Form.where(:form_agency_id => form_agency.id, :number => 'OF-306').should be_empty
        Form.where(:form_agency_id => form_agency.id, :number => 'SF-144').should be_empty
      end
    end

    context 'when there is an existing Form with the same agency and number' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'va.gov',
                           :locale => 'en',
                           :display_name => 'Department of Veterans Affairs')
      end

      let!(:existing_form) do
        Form.create! do |f|
          f.form_agency_id = form_agency.id
          f.number = '10-0137'
          f.title = 'VA Advance Directive: Living Will & Durable Power of Attorney for Health Care'
          f.url = 'http://www.va.gov/form.pdf'
          f.file_type = 'DOC'
          f.verified = false
          f.revision_date = 'today'
        end
      end

      before { va_form.import }

      it 'should create/update forms' do
        Form.where(:form_agency_id => form_agency.id).count.should == 6
      end

      it 'should update existing form' do
        form = Form.where(:form_agency_id => form_agency.id, :number => '10-0137').first
        form.id.should == existing_form.id
        form.url.should == 'http://www.va.gov/vaforms/medical/pdf/vha-10-0137-fill.pdf'
        form.title.should == 'VA Advance Directive: Living Will & Durable Power of Attorney for Health Care'
        form.landing_page_url.should == 'http://www.va.gov/vaforms/form_detail.asp?FormNo=0137'
        form.file_type.should == 'PDF'
        form.revision_date.should == '3/11'
        form.number_of_pages.should == '7'
      end

      it 'should not override verified' do
        Form.where(:form_agency_id => form_agency.id, :number => '10-0137').first.should_not be_verified
      end
    end

    context 'when there is an obsolete Form from the same agency' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'va.gov',
                           :locale => 'en',
                           :display_name => 'Department of Veterans Affairs')
      end

      let!(:obsolete_form) { Form.create!(:form_agency_id => form_agency.id,
                                          :number => 'obsolete',
                                          :title => 'title of an obsolete form',
                                          :url => 'http://www.va.gov/form.pdf',
                                          :file_type => 'PDF') }

      before { va_form.import }

      it 'should create forms' do
        Form.where(:form_agency_id => form_agency.id).count.should == 6
      end

      it 'should delete the obsolete form' do
        Form.find_by_id(obsolete_form.id).should be_nil
      end
    end
  end

  describe '#generate_absolute_url' do
    context 'when the path starts with /forms' do
      specify { va_form.generate_absolute_url('/forms').should == 'http://www.va.gov/forms' }
    end
  end
end
