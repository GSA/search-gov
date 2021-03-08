require 'spec_helper'

describe EmailTemplate do
  before do
    @valid_attributes = {
      name: 'email_template',
      subject: '[USASearch] ',
      body: 'Hello, World.'
    }
  end

  it { is_expected.to validate_presence_of :name }
  it { is_expected.to validate_presence_of :subject }
  it { is_expected.to validate_presence_of :body }
  it 'should create a new instance given valid attributes' do
    described_class.create!(@valid_attributes)
    is_expected.to validate_uniqueness_of(:name).case_insensitive
  end

  describe '#load_default_templates' do
    it 'should load all the templates when no parameter is passed in' do
      described_class.load_default_templates
      expect(described_class.count).to eq(EmailTemplate::DEFAULT_SUBJECT_HASH.size)
    end

    context 'when specifying a specific set of templates' do
      it 'should only reload those templates, and leave the rest alone' do
        expect(described_class.count).to eq(EmailTemplate::DEFAULT_SUBJECT_HASH.size)
        before_time = Time.now
        sleep(1)
        described_class.load_default_templates(%w[affiliate_monthly_report])
        expect(described_class.where('created_at > ?', before_time).size).to eq(1)
      end
    end
  end
end
