describe StatusesController do
  describe '#domain_control_validation' do
    before do
      get :domain_control_validation, params: { affiliate: affiliate.name, format: 'text' }
    end

    context 'when the affiliate does not have a DCV code' do
      let(:affiliate) { affiliates(:basic_affiliate) }

      it { is_expected.to respond_with :not_found }

      it 'returns an error message' do
        expect(response.body).to eq('Domain Control Validation not configured')
      end
    end

    context 'when the affiliate has a DCV code' do
      let(:affiliate) { affiliates(:dcv_affiliate) }

      it { is_expected.to respond_with :success }

      it 'returns the affiliate DCV code' do
        expect(response.body).to eq(affiliate.domain_control_validation_code)
      end
    end
  end
end
