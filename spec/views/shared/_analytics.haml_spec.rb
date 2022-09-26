require 'spec_helper'

describe 'shared/_analytics.haml', pending: 'SRCH-3404' do
  fixtures :affiliates
  let(:affiliate) { affiliates(:basic_affiliate) }

  context 'when DAP is enabled for affiliate' do
    before do
      affiliate.dap_enabled = true
      assign :affiliate, affiliate
    end

    it 'should render federated Google Analytics code' do
      render
      expect(rendered).to have_selector('script', visible: false)
    end
  end

  context 'when DAP is disabled for affiliate' do
    before do
      affiliate.dap_enabled = false
      assign :affiliate, affiliate
    end

    it 'should not render federated Google Analytics code' do
      render
      expect(rendered).to be_blank
    end
  end
end
