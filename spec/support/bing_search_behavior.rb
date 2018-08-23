shared_examples 'a Bing search' do
  let(:offset) { nil }
  let(:limit) { nil }
  let(:filter) { nil }
  let(:enable_highlighting) { nil }
  let(:options) { {
    query: :query,
    offset: offset,
    limit: limit,
    filter: filter,
    language: :language,
    enable_highlighting: enable_highlighting,
  } }

  describe 'params' do
    describe 'offset' do
      context 'when no offset is provided in the options' do
        it 'uses 0' do
          expect(subject.params[:offset]).to eq(0)
        end
      end

      context 'when an offset is provided in the options' do
        let(:offset) { 41 }

        it 'uses the provided offset' do
          expect(subject.params[:offset]).to eq(41)
        end
      end
    end

    describe 'count' do
      context 'when no limit is provided in the options' do
        it 'uses 20' do
          expect(subject.params[:count]).to eq(20)
        end
      end

      context 'when a limit is provided in the options' do
        let(:limit) { 43 }

        it 'uses the provided limit' do
          expect(subject.params[:count]).to eq(43)
        end
      end
    end

    describe 'mkt' do
      before do
        allow(Language).to receive(:bing_market_for_code).with(:language).and_return('hypermarket')
      end

      it 'uses the bing market for the given language code' do
        expect(subject.params[:mkt]).to eq('hypermarket')
      end
    end

    describe 'q' do
      it 'uses the query provided in the options' do
        expect(subject.params[:q]).to eq(:query)
      end
    end

    describe 'safeSearch' do
      context 'when a filter is not provided in the options' do
        it 'uses moderate' do
          expect(subject.params[:safeSearch]).to eq('moderate')
        end
      end

      context 'when a filter is provided in the options' do
        {
          0 => 'off',
          1 => 'moderate',
          2 => 'strict',
          3 => 'moderate',
          4 => 'moderate',
          5 => 'moderate',
        }.each do |filter_option, expected_value|
          context "and the provided filter option is #{filter_option}" do
            let(:filter) { filter_option }

            it "uses #{expected_value}" do
              expect(subject.params[:safeSearch]).to eq(expected_value)
            end
          end
        end
      end
    end

    describe 'responseFilter' do
      it 'always uses WebPages' do
        expect(subject.params[:responseFilter]).to eq('WebPages')
      end
    end

    describe 'textDecorations' do
      context 'when enable_highlighting is not provided in the options' do
        it 'uses false' do
          expect(subject.params[:textDecorations]).to eq(false)
        end
      end

      context 'when enable_highlighting is provided as true in the options' do
        let(:enable_highlighting) { true }

        it 'uses true' do
          expect(subject.params[:textDecorations]).to eq(true)
        end
      end

      context 'when enable_highlighting is provided as false in the options' do
        let(:enable_highlighting) { false }

        it 'uses true' do
          expect(subject.params[:textDecorations]).to eq(false)
        end
      end
    end
  end
end
