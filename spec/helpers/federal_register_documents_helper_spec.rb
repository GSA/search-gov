require 'spec_helper'

describe FederalRegisterDocumentsHelper do
  describe '#federal_register_document_comment_period' do
    let(:document) { mock_model(FederalRegisterDocument) }

    context 'when the document comments_close_on is before today' do
      before { allow(document).to receive(:comments_close_on).and_return Date.current.prev_week }

      specify { expect(helper.federal_register_document_comment_period(document)).to eq 'Comment Period Closed' }
    end

    context 'when the document comments_close_on is today' do
      before { allow(document).to receive(:comments_close_on).and_return Date.current }

      specify { expect(helper.federal_register_document_comment_period(document)).to eq 'Comment period ends today' }
    end
  end
end
