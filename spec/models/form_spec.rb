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
      let!(:form) do
        Form.create!(:form_agency_id => form_agency.id, :number => 'I-9') do |f|
          f.file_type = 'PDF'
          f.title = 'Employment Eligibility Verification'
          f.description = 'All U.S. employers must complete this form.'
          f.url = 'http://www.uscis.gov/files/form/i-9.pdf'
        end
      end

      before do
        Form.reindex
        Affiliate.find(affiliate.id).form_agencies << form_agency
      end

      context 'when query matches form fields' do
        specify { Form.search_for('i-9', affiliate).results.should == [form] }
        specify { Form.search_for('eligible form', affiliate).results.should == [form] }
        specify { Form.search_for('employer form', affiliate).results.should == [form] }
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
