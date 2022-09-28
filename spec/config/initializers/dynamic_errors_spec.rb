# frozen_string_literal: true

class TestModel
  include ActiveModel::Model

  attr_accessor :foo, :bar, :baz_quux
end

describe 'ActiveModel::Errors' do
  let(:test_model) { TestModel.new }

  describe '#full_messages' do
    subject(:full_messages) { test_model.errors.full_messages }

    context 'when the instance is invalid' do
      before do
        test_model.errors.add(:foo)
        test_model.errors.add(:bar, :blank, message: 'is required')
        test_model.errors.add(:baz_quux, 'must be a Float')
      end

      it 'returns a humanized, sorted array of error messages' do
        expect(full_messages).to eq(
          ['Bar is required', 'Baz quux must be a Float', 'Foo is invalid']
        )
      end
    end
  end
end
