# frozen_string_literal: true

require 'spec_helper'

describe I14yDocument do
  let(:drawer) { i14y_drawers(:searchgov) }
  let(:url) { "http://www.foo.gov/#{Time.now.to_i}/bar.html" }
  let(:valid_attributes) do
    { document_id: 'abc123',
      title: 'My document title',
      path: url,
      audience: 'Everyone',
      content_type: 'article',
      created: Time.zone.now.to_s,
      description: 'My fascinating document',
      handle: 'searchgov',
      thumbnail_url: 'https://18f.gsa.gov/assets/img/logos/18F-Logo-M.png',
      click_count: 1000,
      mime_type: 'text/html',
      searchgov_custom1: 'some, custom, content',
      searchgov_custom3: 'more custom content' }
  end
  let(:document) { described_class.new(valid_attributes) }
  let(:i14y_connection) { double(Faraday::Connection) }

  before do
    stub_request(:post, %r{api/v1/documents}).
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
      expect(document.attributes).to include({ document_id: 'abc123',
                                               title: 'My document title',
                                               path: url,
                                               audience: 'Everyone',
                                               click_count: 1000,
                                               content_type: 'article',
                                               created: Time.zone.now.to_s,
                                               description: 'My fascinating document',
                                               thumbnail_url: 'https://18f.gsa.gov/assets/img/logos/18F-Logo-M.png',
                                               mime_type: 'text/html',
                                               searchgov_custom1: 'some, custom, content',
                                               searchgov_custom2: nil,
                                               searchgov_custom3: 'more custom content' })
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
        with('/api/v1/documents', valid_attributes.except(:handle)).
        and_return(Hashie::Mash.new(status: 201))
      document.save
    end

    context 'when the save is unsuccessful' do
      before do
        allow(i14y_connection).to receive(:post).
          with('/api/v1/documents', valid_attributes.except(:handle)).
          and_return(Hashie::Mash.new(status: 400))
      end

      it 'raises an error' do
        expect { document.save }.to raise_error
      end
    end
  end

  describe '.create' do
    it 'returns the document' do
      expect(described_class.create(valid_attributes)).
        to be_an_instance_of(described_class)
    end
  end

  describe '.update' do
    let(:update) do
      { document_id: 'update_me', title: 'My New Title', handle: 'searchgov' }
    end

    before do
      allow_any_instance_of(described_class).to receive(:i14y_connection).and_return(i14y_connection)
    end

    it 'updates the document' do
      expect(i14y_connection).to receive(:put).
        with('/api/v1/documents/update_me', { title: 'My New Title' }).
        and_return(Hashie::Mash.new(status: 200))
      described_class.update(update)
    end

    it 'check if thumbnail_url is valid' do
      update[:thumbnail_url] = 'http://www.foo.gov/assets/img/logos/18F-Logo-M.png'
      expect(i14y_connection).to receive(:put).
        with('/api/v1/documents/update_me', { title: 'My New Title',
                                              thumbnail_url: 'http://www.foo.gov/assets/img/logos/18F-Logo-M.png' }).
        and_return(Hashie::Mash.new(status: 200))
      described_class.update(update)
    end

    it 'update document with absolute thumbnail_url' do
      update[:thumbnail_url] = 'assets/img/logos/18F-Logo-M.png'
      update[:path] = url
      expect(i14y_connection).to receive(:put).
        with('/api/v1/documents/update_me', { title: 'My New Title', path: url,
                                              thumbnail_url: 'http://www.foo.gov/assets/img/logos/18F-Logo-M.png' }).
        and_return(Hashie::Mash.new(status: 200))
      described_class.update(update)
    end

    context 'when the update fails' do
      before do
        allow(i14y_connection).to receive(:put).
          with('/api/v1/documents/nonexistent', { title: 'fail' }).
          and_return(Hashie::Mash.new(status: 400, body: { developer_message: 'failure' }))
      end

      it 'raises an error' do
        expect { described_class.update(document_id: 'nonexistent', title: 'fail') }.
          to raise_error(I14yDocument::I14yDocumentError)
      end
    end
  end

  describe '.delete' do
    subject(:delete) { described_class.delete(handle: 'my_drawer', document_id: 'delete_me') }

    let(:drawer) { mock_model(I14yDrawer) }

    before do
      allow(I14yDrawer).to receive(:find_by).with(handle: 'my_drawer').and_return(drawer)
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
          with('/api/v1/documents/delete_me').
          and_return(Hashie::Mash.new(status: 400, body: { developer_message: 'not found' }))
      end

      it 'raises an error' do
        expect { delete }.to raise_error(I14yDocument::I14yDocumentError)
      end
    end
  end

  describe '.promote' do
    before { allow_any_instance_of(described_class).to receive(:i14y_connection).and_return(i14y_connection) }

    it 'promotes the document' do
      expect(i14y_connection).to receive(:put).
        with('/api/v1/documents/promote_me', { promote: 'true' }).
        and_return(Hashie::Mash.new(status: 200))
      described_class.promote(handle: 'my_drawer', document_id: 'promote_me')
    end

    it 'accepts a boolean value for demoting docs' do
      expect(i14y_connection).to receive(:put).
        with('/api/v1/documents/promote_me', { promote: 'false' }).
        and_return(Hashie::Mash.new(status: 200))
      described_class.promote(handle: 'my_drawer', document_id: 'promote_me', bool: 'false')
    end
  end
end
