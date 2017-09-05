require 'spec_helper'

describe I14yDocument do
  fixtures :i14y_drawers

  let(:drawer) { i14y_drawers(:searchgov) }
  let(:url) { "http://www.foo.gov/#{Time.now.to_i}/bar.html" }
  let(:valid_attributes) do
    { document_id: url,
      title: 'My document title',
      path: url,
      created: Time.now.to_s,
      description: 'My fascinating document',
      handle: 'searchgov'
    }
  end
  let(:document) { I14yDocument.new(valid_attributes) }
  before do
    stub_request(:post, %r(api/v1/documents)).
      to_return({ status: 201, body: { user_message: 'success', status: 200 }.to_json })
  end

  describe 'validations' do
    it { should validate_presence_of :path }
    it { should validate_presence_of :handle }
    it { should validate_presence_of :document_id }
    it { should validate_presence_of :title }
  end

  describe '#attributes' do
    it 'returns a hash of the attributes' do
      expect(document.attributes).to include({ document_id: url })
    end
  end

  describe '#i14y_drawer' do
    it 'returns the drawer associated with the document' do
      expect(document.i14y_drawer).to eq drawer
    end
  end

  describe '#save' do
    let(:i14y_connection) { double(Faraday::Connection) }
    before { document.stub(:i14y_connection).and_return(i14y_connection) }

    it 'saves the document in the I14y index' do
      expect(i14y_connection).to receive(:post).
        with("/api/v1/documents", valid_attributes.except(:handle)).
        and_return(Hashie::Mash.new(status: 201))
      document.save
    end

    context 'when the save is unsuccessful' do
      before do
        allow(i14y_connection).to receive(:post).
          with("/api/v1/documents", valid_attributes.except(:handle)).
          and_return(Hashie::Mash.new(status: 400))
      end

      it 'raises an error' do
        expect{ document.save }.to raise_error
      end
    end
  end

  describe '#create' do
    it 'returns the document' do
      expect(I14yDocument.create(valid_attributes))
        .to be_an_instance_of(I14yDocument)
    end
  end
end
