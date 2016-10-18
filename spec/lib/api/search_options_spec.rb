require 'spec_helper'

describe Api::SearchOptions do
  describe '#valid?' do
    before { Affiliate.should_not_receive(:find_by_name) }

    it { should validate_inclusion_of(:file_type).in_array(%w(doc pdf ppt txt xls)) }
    it { should validate_inclusion_of(:filter).in_array(%w(0 1 2)) }

    context 'when the query is too long' do
      let(:query) do
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries"
      end

      subject(:options) { described_class.new(query: query) }

      it 'returns false' do
        expect(options).not_to be_valid
        expect(options.errors.full_messages).to include('query is too long (maximum is 255 characters)')
      end
    end

    context 'when the affiliate is blank' do
      subject(:options) { described_class.new }

      it 'returns false' do
        expect(options).not_to be_valid
        expect(options.errors.full_messages).to include('affiliate must be present')
      end
    end
  end

  describe '#valid?(:affiliate)' do
    context 'when the affiliate does not exist' do
      subject(:options) do
        described_class.new(access_key: 'my_access_key',
                            affiliate: 'my_site_handle',
                            query: 'gov')
      end

      before do
        Affiliate.should_receive(:find_by_name).with('my_site_handle').and_return(nil)
      end

      it 'returns false' do
        expect(options).not_to be_valid(:affiliate)
        expect(options.errors.full_messages).to include('affiliate not found')
      end
    end
  end
end
