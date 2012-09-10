require 'spec_helper'

describe SsaForm do
  before(:all) { FormAgency.destroy_all }
  let(:rocis_data_path) { "#{Rails.root}/spec/fixtures/csv/forms/rocis_data.csv" }
  let(:ssa_form) { SsaForm.new(RocisData.new(rocis_data_path).to_hash) }

  describe '#import' do
    let(:ssa_json) { File.read("#{Rails.root}/spec/fixtures/json/forms/ssa/forms.json") }
    let(:ssa_file) { mock(File, :read => ssa_json) }

    before do
      ssa_form.should_receive(:open).
          with('http://www.socialsecurity.gov/online/forms.json').
          and_return(ssa_file)
    end

    context 'when there is no exisiting FormAgency' do
      before { ssa_form.import }

      it 'should create FormAgency' do
        FormAgency.count.should == 1
        FormAgency.first.name.should == 'ssa.gov'
        FormAgency.first.locale.should == 'en'
        FormAgency.first.display_name.should == 'Social Security Administration'
      end
    end

    context 'when there is no existing Form' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'ssa.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Social Security Administration')
      end

      before { ssa_form.import }

      it 'should not create a new FormAgency' do
        FormAgency.count.should == 1
        FormAgency.first.should == form_agency
      end

      it 'should update FormAgency display name' do
        FormAgency.first.display_name.should == 'Social Security Administration'
      end

      it 'should create forms' do
        Form.count.should == 4
      end

      it 'should populate all the available fields' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'SSA-44').first
        form.title.should == 'Medicare Income-Related Monthly Adjustment Amount - Life-Changing Event'
        form.url.should == 'http://www.socialsecurity.gov/online/ssa-44.pdf'
        form.file_type.should == 'PDF'
        form.should be_verified
      end

      it 'should populate rocis fields' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'SSA-10').first
        form.expiration_date.strftime('%-m/%-d/%y').should == '3/31/13'
        form.abstract.should =~ /^SSA uses the information from the SSA-10-BK/
        form.abstract.should =~ /The respondents are applicants for widow's or widower's Social Security benefits\.$/
        form.line_of_business.should == 'Income Security'
        form.subfunction.should == 'General Retirement and Disability'
        form.public_code.should == 'Individuals or Households'
      end

      it 'should populate form links' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'SSA-44').first
        form.links[0][:title].should == 'Form SSA-44'
        form.links[0][:url].should == 'http://www.socialsecurity.gov/online/ssa-44.pdf'
        form.links[0][:file_type].should == 'PDF'
      end

      it 'should populate landing_page_url' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'SSA-545').first
        form.landing_page_url.should == 'http://www.socialsecurity.gov/online/ssa-545.html'
        form.url.should == 'http://www.socialsecurity.gov/online/ssa-545.pdf'
      end

      it 'should not create Spanish forms' do
        Form.where(:form_agency_id => form_agency.id, :number => 'SSA-3-SP').should be_blank
      end
    end

    context 'when there is existing Form with the same agency and number' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'ssa.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Social Security Administration')
      end

      let!(:existing_form) do
        Form.create! do |f|
          f.form_agency_id = form_agency.id
          f.number = 'SSA-44'
          f.title = 'Medicare Income-Related Monthly Adjustment Amount - Life-Changing Event'
          f.url = 'http://www.ssa.gov/form.pdf'
          f.file_type = 'PDF'
          f.verified = false
          f.number_of_pages = 100
        end
      end

      before { ssa_form.import }

      it 'should create/update forms' do
        Form.where(:form_agency_id => form_agency.id).count.should == 4
      end

      it 'should update existing form' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'SSA-44').first
        form.id.should == existing_form.id
        form.title.should == 'Medicare Income-Related Monthly Adjustment Amount - Life-Changing Event'
        form.url.should == 'http://www.socialsecurity.gov/online/ssa-44.pdf'
        form.abstract.should =~ /\APer the Medicare Modernization Act of 2003/
        form.abstract.should =~ /emergency basis several months ago\.\Z/
        form.file_type.should == 'PDF'
        form.expiration_date.strftime('%-m/%-d/%y').should == '7/31/14'
      end

      it 'should reset details fields' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'SSA-44').first
        form.number_of_pages.should be_nil
      end

      it 'should not override verified' do
        Form.where(:form_agency_id => form_agency.id, :number => 'SSA-44').first.should_not be_verified
      end
    end

    context 'when there is an obsolete Form from the same agency' do
      let!(:form_agency) do
        FormAgency.create!(:name => 'ssa.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Social Security Administration')
      end

      let!(:obsolete_form) { Form.create!(:form_agency_id => form_agency.id,
                                          :number => 'obsolete',
                                          :title => 'title of an obsolete form',
                                          :url => 'http://www.ssa.gov/form.pdf',
                                          :file_type => 'PDF') }

      before { ssa_form.import }

      it 'should create forms' do
        Form.where(:form_agency_id => form_agency.id).count.should == 4
      end

      it 'should delete the obsolete form' do
        Form.find_by_id(obsolete_form.id).should be_nil
      end
    end

    context 'when there is a matching usagov FAQs IndexedDocuments' do
      fixtures :affiliates

      let!(:form_agency) do
        FormAgency.create!(:name => 'ssa.gov',
                           :locale => 'en',
                           :display_name => 'U.S. Social Security Administration')
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
                                :title => 'some docs about form SSA-44',
                                :description => 'some title about form SSA-44',
                                :url => 'http://answers.usa.gov/page1.html',
                                :doctype => 'html',
                                :last_crawl_status => IndexedDocument::OK_STATUS)
      end

      let!(:indexed_document2) do
        IndexedDocument.create!(:affiliate_id => usagov.id,
                                :title => 'another docs about form SSA-44',
                                :description => 'another title about form SSA-44',
                                :url => 'http://answers.usa.gov/page2.html',
                                :doctype => 'html',
                                :last_crawl_status => IndexedDocument::OK_STATUS)
      end

      let(:dc) { mock('dc', :count => 1, :first => faqs) }
      let(:odies) { mock('odies', :results => [indexed_document1, indexed_document2])}

      before do
        IndexedDocument.reindex
        ssa_form.import
      end

      it 'should create FormsIndexedDocuments' do
        form = Form.where(:form_agency_id => form_agency.id, :number => 'SSA-44').first
        form.indexed_documents.count.should == 2
        form.indexed_documents.should include indexed_document1
        form.indexed_documents.should include indexed_document2
      end
    end
  end
end
