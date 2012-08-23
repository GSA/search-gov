# coding: utf-8
require 'spec_helper'

describe Form do
  it { should validate_presence_of :form_agency_id }
  it { should validate_presence_of :number }
  it { should validate_presence_of :url }
  it { should validate_presence_of :file_type }
  it { should belong_to :form_agency }
  it { should have_and_belong_to_many :indexed_documents }

  describe '.search_for' do
    fixtures :affiliates, :form_agencies

    let(:affiliate) { affiliates(:basic_affiliate) }
    let(:form_agency) { form_agencies(:en_uscis) }

    context 'when sanitized query is blank' do
      before do
        Affiliate.find(affiliate.id).form_agencies << form_agency
        Form.should_receive(:preprocess).and_return(nil)
        ActiveSupport::Notifications.should_not_receive(:instrument)
      end

      specify { Form.search_for('some query', affiliate).should be_nil }
    end

    context 'when the affiliate FormAgency has forms' do
      let!(:form1) do
        Form.create!(:form_agency_id => form_agency.id, :number => 'I-9') do |f|
          f.file_type = 'PDF'
          f.title = 'Employment Eligibility Verification'
          f.description = 'All U.S. employers must complete this form.'
          f.url = 'http://www.uscis.gov/files/form/i-9.pdf'
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
          f.file_type = 'PDF'
          f.title = 'Instructions for I-485, Supplement E'
          f.description = 'To provide additional instructions for filing of adjustment of status (Form I-485).'
          f.url = 'http://www.uscis.gov/files/form/i-485supe.pdf'
        end
      end

      before do
        Form.reindex
        Affiliate.find(affiliate.id).form_agencies << form_agency
      end

      context 'when query matches form fields' do
        specify { Form.search_for('i-9', affiliate).results.should == [form1] }
        specify { Form.search_for('i 9', affiliate).results.should == [form1] }
        specify { Form.search_for('i9', affiliate).results.should == [form1] }
        specify { Form.search_for('i-129f', affiliate).results.should == [form2] }
        specify { Form.search_for('i 129f', affiliate).results.should == [form2] }
        specify { Form.search_for('i129f', affiliate).results.should == [form2] }
        specify { Form.search_for('eligible form', affiliate).results.should == [form1] }
        specify { Form.search_for('employer form', affiliate).results.should == [form1] }
        specify { Form.search_for('i-485', affiliate).results.should == [form4] }
        specify { Form.search_for('i 485', affiliate).results.should == [form4] }
        specify { Form.search_for('i485', affiliate).results.should == [form4] }
        specify { Form.search_for('i-485 supplement e', affiliate).results.should == [form5] }
      end

      context 'highlights' do
        specify { Form.search_for('i-9', affiliate).hits.first.highlights(:number_text).should_not be_blank }
        specify { Form.search_for('i 9', affiliate).hits.first.highlights(:number_text).should_not be_blank }
        specify { Form.search_for('i9', affiliate).hits.first.highlights(:number_text).should_not be_blank }

        specify { Form.search_for('i-129f', affiliate).hits.first.highlights(:number_text).should_not be_blank }
        specify { Form.search_for('i 129f', affiliate).hits.first.highlights(:number_text).should_not be_blank }
        specify { Form.search_for('i129f', affiliate).hits.first.highlights(:number_text).should_not be_blank }

        specify { Form.search_for('i-485 supplement e', affiliate).hits.first.highlights(:number_text).should_not be_blank }
        specify { Form.search_for('i 485 supplement e', affiliate).hits.first.highlights(:number_text).should_not be_blank }
        specify { Form.search_for('i485 supplement e', affiliate).hits.first.highlights(:number_text).should_not be_blank }

        specify { Form.search_for('i-485 supplement e', affiliate).hits.first.highlights(:title_text).should_not be_blank }
        specify { Form.search_for('i 485 supplement e', affiliate).hits.first.highlights(:title_text).should_not be_blank }
        specify { Form.search_for('i485 supplement e', affiliate).hits.first.highlights(:title_text).should_not be_blank }

        specify { Form.search_for('i-485 supplement e', affiliate).hits.first.highlights(:description).should_not be_blank }
      end

      context 'when query does not match form fields' do
        specify { Form.search_for('some query form', affiliate).results.should be_empty }
      end
    end

    context 'when .search raise an exception' do
      it 'should return nil' do
        Form.should_receive(:search).and_raise(RSolr::Error::Http.new({}, {}))
        Form.search_for('form I-9', affiliate).should be_nil
      end
    end
  end
end
