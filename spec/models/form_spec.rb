# coding: utf-8
require 'spec_helper'

describe Form do
  it { should validate_presence_of :form_agency_id }
  it { should validate_presence_of :number }
  it { should validate_presence_of :url }
  it { should validate_presence_of :file_type }
  it { should validate_presence_of :title }
  it { should belong_to :form_agency }
  it { should have_and_belong_to_many :indexed_documents }

  describe '.govbox_search_for(query, form_agency_ids)' do

    context 'when the query qualifies for form fulltext search' do
      let(:form_agency_ids) { [1, 2, 3] }

      ['1099-DIV', 'disability forms'].each do |query|
        it 'should execute Form.search_for' do
          Form.should_receive(:search_for).with(query, {:form_agencies => form_agency_ids, :verified => true, :count => 1}).and_return('forms stuff')
          Form.govbox_search_for(query, form_agency_ids).should == 'forms stuff'
        end
      end
    end

    context 'when the query does not qualify for form fulltext search' do
      let(:form_agency) { FormAgency.create!(:display_name => 'FEMA Agency', :locale => 'en', :name => 'fema.gov') }

      before do
        form_agency.forms.create!(:number => '99', :file_type => 'PDF') do |f|
          f.title = 'Personal Property'
          f.url = 'fema.gov/some_form.pdf'
          f.description = 'contains the word FEMA'
        end
        form_agency.forms.create!(:number => '70', :file_type => 'PDF') do |f|
          f.title = 'Unverified Document'
          f.url = 'fema.gov/some_form-800.pdf'
          f.verified = false
        end
      end

      context 'when matching forms exist' do
        let(:query) { 'Personal Property' }

        it 'should return an array of forms' do
          forms = Form.govbox_search_for(query, [form_agency.id])
          forms.total.should == 1
          forms.hits.should be_nil
          forms.results.count.should == 1
          forms.results.first.number.should == '99'
          forms.results.first.title.should == 'Personal Property'
        end
      end

      context 'when the query matches unverified form' do
        let(:query) { 'Unverified Document' }

        it 'should not return unverified forms' do
          forms = Form.govbox_search_for(query, [form_agency.id])
          forms.total.should == 0
          forms.hits.should be_nil
          forms.results.should be_empty
        end
      end

      context 'when the non-fulltext search query matches nothing' do
        let(:query) { 'forms' }

        it 'should return empty results' do
          forms = Form.govbox_search_for(query, [form_agency.id])
          forms.total.should == 0
          forms.hits.should be_nil
          forms.results.should be_empty
        end
      end
    end
  end

  describe '.search_for(query, options)' do
    let(:form_agency) { FormAgency.create!(:display_name => 'FEMA Agency', :locale => 'en', :name => 'fema.gov') }

    context 'when the FormAgency has forms' do
      let!(:form1) do
        Form.create!(:form_agency_id => form_agency.id, :number => 'I-9') do |f|
          f.file_type = 'PDF'
          f.title = 'Employment Eligibility Verification'
          f.description = 'All U.S. employers must complete this form.'
          f.url = 'http://www.uscis.gov/files/form/i-9.pdf'
          f.abstract = 'some of the shortest government agency form'
        end
      end

      let!(:form2) do
        Form.create!(:form_agency_id => form_agency.id, :number => 'I-129F') do |f|
          f.file_type = 'PDF'
          f.title = 'Petition for Alien Fiancé(e)'
          f.description = 'To petition to bring your fiancé(e) (K-1)'
          f.url = 'http://www.uscis.gov/files/form/i-129f.pdf'
        end
      end

      let(:form3) do
        Form.create!(:form_agency_id => form_agency.id, :number => 'I-539') do |f|
          f.file_type = 'PDF'
          f.title = 'Application To Extend/Change Nonimmigrant Status'
          f.description = "Please see the form's instructions for your specific nonimmigrant visa category."
          f.url = 'http://www.uscis.gov/files/form/i-539.pdf'
        end
      end

      let!(:form4) do
        Form.create!(:form_agency_id => form_agency.id, :number => 'I-485') do |f|
          f.file_type = 'PDF'
          f.title = 'Application to Register Permanent Residence or Adjust Status'
          f.description = 'To apply to adjust your status to that of a permanent resident of the United States.'
          f.url = 'http://www.uscis.gov/files/form/i-485.pdf'
        end
      end

      let!(:form5) do
        Form.create!(:form_agency_id => form_agency.id, :number => 'I-485 Supplement E') do |f|
          f.file_type = 'Online'
          f.title = 'Instructions for I-485, Supplement E'
          f.description = 'To provide additional instructions for filing of adjustment of status (Form I-485).'
          f.url = 'http://www.uscis.gov/files/form/i-485supe.pdf'
          f.subfunction = "foo"
          f.public_code = "bar"
          f.line_of_business = "blat"
        end
      end

      before do
        Form.reindex
      end

      context 'when query matches form fields' do
        specify { Form.search_for('i-9').results.should == [form1] }
        specify { Form.search_for('i 9').results.should == [form1] }
        specify { Form.search_for('i9').results.should == [form1] }
        specify { Form.search_for('i-129f').results.should == [form2] }
        specify { Form.search_for('i 129f').results.should == [form2] }
        specify { Form.search_for('i129f').results.should == [form2] }
        specify { Form.search_for('eligible form').results.should == [form1] }
        specify { Form.search_for('employer form').results.should == [form1] }
        specify { Form.search_for('i-485').results.first.should == form4 }
        specify { Form.search_for('i 485').results.first.should == form4 }
        specify { Form.search_for('i485').results.first.should == form4 }
        specify { Form.search_for('i-485 supplement e').results.should == [form5] }
        specify { Form.search_for('', {:form_agencies => [form5.form_agency.id, form5.form_agency.id + 1, form5.form_agency.id + 2], :subfunction => 'foo', :public_code => 'bar', :file_type => 'Online', :line_of_business => 'blat', :count => 1}).results.should == [form5] }
      end

      it 'should do fulltext search on abstract' do
        Form.search_for('governing').results.should == [form1]
      end

      context 'highlights' do
        specify { Form.search_for('i-9').hits.first.highlights(:number_text).should_not be_blank }
        specify { Form.search_for('i 9').hits.first.highlights(:number_text).should_not be_blank }
        specify { Form.search_for('i9').hits.first.highlights(:number_text).should_not be_blank }

        specify { Form.search_for('i-129f').hits.first.highlights(:number_text).should_not be_blank }
        specify { Form.search_for('i 129f').hits.first.highlights(:number_text).should_not be_blank }
        specify { Form.search_for('i129f').hits.first.highlights(:number_text).should_not be_blank }

        specify { Form.search_for('i-485 supplement e').hits.first.highlights(:number_text).should_not be_blank }
        specify { Form.search_for('i 485 supplement e').hits.first.highlights(:number_text).should_not be_blank }
        specify { Form.search_for('i485 supplement e').hits.first.highlights(:number_text).should_not be_blank }

        specify { Form.search_for('i-485 supplement e').hits.first.highlights(:title_text).should_not be_blank }
        specify { Form.search_for('i 485 supplement e').hits.first.highlights(:title_text).should_not be_blank }
        specify { Form.search_for('i485 supplement e').hits.first.highlights(:title_text).should_not be_blank }

        specify { Form.search_for('i-485 supplement e').hits.first.highlights(:description).should_not be_blank }
      end

      context 'when query does not match form fields' do
        specify { Form.search_for('some query form').results.should be_empty }
      end

      context 'govbox enabled' do
        before do
          form4.update_attributes!(:verified => false)
          form5.update_attributes!(:verified => true)
          Form.reindex
        end
        specify { Form.search_for('i-485', {:verified => true}).results.should == [form5] }
      end
    end

    context 'when .search raise an exception' do
      it 'should return nil' do
        Form.should_receive(:search).and_raise(RSolr::Error::Http.new({}, {}))
        Form.search_for('form I-9').should be_nil
      end
    end
  end
end
