shared_examples 'a Bing search' do
  let(:offset) { nil }
  let(:limit) { nil }
  let(:filter) { nil }
  let(:enable_highlighting) { nil }
  let(:options) do
    { query: :query,
      offset: offset,
      limit: limit,
      filter: filter,
      language: :language,
      enable_highlighting: enable_highlighting }
  end

  describe 'params' do
    describe 'offset' do
      context 'when no offset is provided in the options' do
        it 'uses 0' do
          expect(search.params[:offset]).to eq(0)
        end
      end

      context 'when an offset is provided in the options' do
        let(:offset) { 41 }

        it 'uses the provided offset' do
          expect(search.params[:offset]).to eq(41)
        end
      end
    end

    describe 'count' do
      context 'when no limit is provided in the options' do
        it 'uses 20' do
          expect(search.params[:count]).to eq(20)
        end
      end

      context 'when a limit is provided in the options' do
        let(:limit) { 43 }

        it 'uses the provided limit' do
          expect(search.params[:count]).to eq(43)
        end
      end
    end

    describe 'mkt' do
      before do
        allow(Language).to receive(:bing_market_for_code).with(:language).and_return('hypermarket')
      end

      it 'uses the bing market for the given language code' do
        expect(search.params[:mkt]).to eq('hypermarket')
      end
    end

    describe 'q' do
      it 'uses the query provided in the options' do
        expect(search.params[:q]).to eq(:query)
      end
    end

    describe 'safeSearch' do
      context 'when a filter is not provided in the options' do
        it 'uses moderate' do
          expect(search.params[:safeSearch]).to eq('moderate')
        end
      end

      context 'when a filter is provided in the options' do
        {
          0 => 'off',
          1 => 'moderate',
          2 => 'strict',
          3 => 'moderate',
          4 => 'moderate',
          5 => 'moderate'
        }.each do |filter_option, expected_value|
          context "when the provided filter option is #{filter_option}" do
            let(:filter) { filter_option }

            it "uses #{expected_value}" do
              expect(search.params[:safeSearch]).to eq(expected_value)
            end
          end
        end
      end
    end

    describe 'responseFilter' do
      it 'always uses WebPages' do
        expect(search.params[:responseFilter]).to eq('WebPages')
      end
    end

    describe 'textDecorations' do
      context 'when enable_highlighting is not provided in the options' do
        it 'uses false' do
          expect(search.params[:textDecorations]).to be(false)
        end
      end

      context 'when enable_highlighting is provided as true in the options' do
        let(:enable_highlighting) { true }

        it 'uses true' do
          expect(search.params[:textDecorations]).to be(true)
        end
      end

      context 'when enable_highlighting is provided as false in the options' do
        let(:enable_highlighting) { false }

        it 'uses true' do
          expect(search.params[:textDecorations]).to be(false)
        end
      end
    end
  end

  describe '#execute_query' do
    subject(:search) { described_class.new(options) }

    context 'when Bing returns an error' do
      before do
        stub_request(:get, /bing/).to_return({ body: bing_response_body })
      end

      context 'when the type is an error response' do
        let(:bing_response_body) do
          {
            _type: 'ErrorResponse',
            errors: [
              {
                code: 'InvalidRequest',
                subCode: 'ParameterMissing',
                message: 'Required parameter is missing.',
                parameter: 'q'
              }
            ]
          }.to_json
        end

        it 'raises an exception' do
          expect { search.execute_query }.to raise_error('Required parameter is missing.')
        end
      end

      context 'when Bing returns an error status code' do
        let(:bing_response_body) { '{"status_code":401,"message":"bad key"}' }

        it 'raises an exception' do
          expect { search.execute_query }.to raise_error('received status code 401 - bad key')
        end
      end
    end
  end
end
