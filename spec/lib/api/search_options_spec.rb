require 'spec_helper'

describe Api::SearchOptions, type: :model do
  subject(:options) do
    described_class.new(params)
  end

  let(:params) do
    {}
  end

  describe 'initialization' do
    context 'when the query params include HTML tags' do
      let(:unsanitized_query) { '<b>thunder & lightning</b>' }
      let(:params) do
        {
          query: unsanitized_query,
          query_not: unsanitized_query,
          query_or: unsanitized_query,
          query_quote: unsanitized_query
        }
      end

      it 'sanitizes the query params' do
        expect(
          [
            options.query,
            options.query_not,
            options.query_or,
            options.query_quote
          ]
        ).to all eq 'thunder & lightning'
      end
    end
  end

  describe '#valid?' do
    before { expect(Affiliate).not_to receive(:find_by_name) }

    it { is_expected.to validate_inclusion_of(:filter).in_array(%w(0 1 2)) }

    context 'when the query is too long' do
      subject(:options) { described_class.new(query: query) }

      let(:query) do
        "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book. It has survived not only five centuries"
      end

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

    context 'when no query is included' do
      subject(:options) { described_class.new(query: '' ) }

      it 'requires a query' do
        expect(options).not_to be_valid
        expect(options.errors.full_messages).to include('a search term must be present')
      end
    end

    context 'when any search term is included' do
      let(:options) do
        { access_key: 'my_access_key', affiliate: 'my_site_handle' }
      end

      %i(query query_not query_quote query_or).each do |param|
        it "is valid if #{param} is present" do
          expect(described_class.new(options.merge({param => 'foo'}))).to be_valid
        end
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
        expect(Affiliate).to receive(:active).twice
        allow(Affiliate).to receive_message_chain(:active, :find_by_name).with('my_site_handle').and_return(nil)
      end

      it 'returns false' do
        expect(options).not_to be_valid(:affiliate)
        expect(options.errors.full_messages).to include('affiliate not found')
      end
    end
  end
end
