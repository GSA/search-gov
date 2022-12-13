# frozen_string_literal: true

describe SearchGovInterceptor do
  let(:interceptor) { described_class.new(force_to) }

  describe '#delivering_email' do
    subject(:delivering_email) { interceptor.delivering_email(message) }

    let(:message) { Mail::Message.new(to: 'recipient@gsa.gov') }

    context 'when no force_to address is specified' do
      let(:force_to) { nil }

      it 'directs email to the recipient' do
        expect { delivering_email }.not_to change { message.to }
      end
    end

    context 'when a force_to address is specified' do
      let(:force_to) { 'forced@gsa.gov' }

      it 'directs email to the forced email address' do
        expect { delivering_email }.to change { message.to }.
          from(['recipient@gsa.gov']).to(['forced@gsa.gov'])
      end
    end
  end
end
