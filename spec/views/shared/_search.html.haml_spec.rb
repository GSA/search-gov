require 'spec_helper'
describe 'shared/_search.html.haml' do
  before do
    @search = double('Search')
    allow(@search).to receive(:query).and_return nil
    allow(@search).to receive(:filter_setting).and_return nil
    allow(@search).to receive(:scope_id).and_return nil
    assign(:search, @search)
    allow(view).to receive(:path).and_return search_path
  end

  context 'when page is displayed' do
    before do
      @affiliate = double('Affiliate', name: 'aff.gov', is_sayt_enabled: false)
      assign(:affiliate, @affiliate)
    end

    context 'when a scope id is specified' do
      before do
        allow(@search).to receive(:scope_id).and_return 'SomeScope'
        assign(:scope_id, 'SomeScope')
      end

      it 'should include a hidden tag with the scope id' do
        expect(@search.scope_id).to eq('SomeScope')
        render
        expect(rendered).to have_selector("input[type='hidden'][id='scope_id'][value='SomeScope']", visible: false)
      end
    end
  end
end
