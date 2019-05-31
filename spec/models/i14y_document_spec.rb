require 'spec_helper'

describe I14yDocument do
  fixtures :i14y_drawers

  let(:drawer) { i14y_drawers(:searchgov) }
  let(:url) { "http://www.foo.gov/#{Time.now.to_i}/bar.html" }
  let(:valid_attributes) do
    { document_id: 'abc123',
      title: 'My document title',
      path: url,
      created: Time.now.to_s,
      description: 'My fascinating document',
      handle: 'searchgov',
      click_count: 1000
    }
  end
  let(:document) { I14yDocument.new(valid_attributes) }
  let(:i14y_connection) { double(Faraday::Connection) }
  before do
    stub_request(:post, %r(api/v1/documents)).
      to_return({ status: 201, body: { user_message: 'success', status: 200 }.to_json })
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :path }
    it { is_expected.to validate_presence_of :handle }
    it { is_expected.to validate_presence_of :document_id }
    it { is_expected.to validate_presence_of :title }
  end

  describe '#attributes' do
    it 'returns a hash of the attributes' do
      expect(document.attributes).to include({ document_id: 'abc123' })
    end
  end

  describe '#i14y_drawer' do
    it 'returns the drawer associated with the document' do
      expect(document.i14y_drawer).to eq drawer
    end
  end

  describe '#save' do
    before { allow(document).to receive(:i14y_connection).and_return(i14y_connection) }

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

  describe '.create' do
    it 'returns the document' do
      expect(I14yDocument.create(valid_attributes))
        .to be_an_instance_of(I14yDocument)
    end
  end

  describe '.update' do
    let(:update_attributes) do
      { document_id: 'update_me', title: 'My New Title', handle: 'searchgov' }
    end
    before do
      allow_any_instance_of(I14yDocument).to receive(:i14y_connection).and_return(i14y_connection)
    end

    it 'updates the document' do
      expect(i14y_connection).to receive(:put).
        with("/api/v1/documents/update_me", { title: 'My New Title' }).
        and_return(Hashie::Mash.new(status: 200))
      I14yDocument.update(update_attributes)
    end

    context 'when the update fails' do
      before do
        allow(i14y_connection).to receive(:put).
          with("/api/v1/documents/nonexistent", { title: 'fail' }).
          and_return(Hashie::Mash.new(status: 400, body: { developer_message: 'failure' }))
      end

      it 'raises an error' do
        expect{ I14yDocument.update(document_id: 'nonexistent', title: 'fail') }.
          to raise_error(I14yDocument::I14yDocumentError)
      end
    end
  end

  describe '.delete' do
    subject(:delete) { I14yDocument.delete(handle: 'my_drawer', document_id: 'delete_me') }

    let(:drawer) { mock_model(I14yDrawer) }

    before do
      allow(I14yDrawer).to receive(:find_by_handle).with('my_drawer').and_return(drawer)
      allow(drawer).to receive(:i14y_connection).and_return(i14y_connection)
    end

    it 'deletes the document' do
      expect(i14y_connection).to receive(:delete).with('/api/v1/documents/delete_me').
        and_return(Hashie::Mash.new(status: 200))
      delete
    end

    context 'when the deletion fails' do
      before do
        allow(i14y_connection).to receive(:delete).
          with("/api/v1/documents/delete_me").
          and_return(Hashie::Mash.new(status: 400, body: { developer_message: 'not found' }))
      end

      it 'raises an error' do
        expect{ delete }.to raise_error(I14yDocument::I14yDocumentError)
      end
    end
  end

  describe '.promote' do
    before { allow_any_instance_of(I14yDocument).to receive(:i14y_connection).and_return(i14y_connection) }

    it 'promotes the document' do
      expect(i14y_connection).to receive(:put).
        with("/api/v1/documents/promote_me", { promote: 'true' }).
        and_return(Hashie::Mash.new(status: 200))
      I14yDocument.promote(handle: 'my_drawer', document_id: 'promote_me')
    end

    it 'accepts a boolean value for demoting docs' do
      expect(i14y_connection).to receive(:put).
        with("/api/v1/documents/promote_me", { promote: 'false' }).
        and_return(Hashie::Mash.new(status: 200))
      I14yDocument.promote(handle: 'my_drawer', document_id: 'promote_me', bool: 'false')
    end
  end
end
