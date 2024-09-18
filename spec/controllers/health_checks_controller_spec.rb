require 'spec_helper'

describe HealthChecksController do
  describe '#new' do
    context 'when the database is accessible' do
      it 'produces a successful response' do
        get :new
        expect(response).to be_successful
      end
    end

    context 'when the database is not accessible' do
      before { allow(Language).to receive(:first).and_raise(Mysql2::Error.new('trouble')) }

      it 'raises a Mysql2::Error' do
        expect { get :new }.to raise_error(Mysql2::Error, 'trouble')
      end
    end
  end
end
