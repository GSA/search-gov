require 'spec_helper'

describe BoostedContentKeyword do
  fixtures :boosted_contents

  it { is_expected.to validate_presence_of :value }
  it { is_expected.to belong_to :boosted_content }
  it { is_expected.not_to allow_value('piped|keywords').for(:value) }
  it { is_expected.not_to allow_value('comma,separated,keywords').for(:value) }

  let!(:keyword) do
    boosted_contents(:basic).boosted_content_keywords.create!(value: '  barack   obama  ')
  end

  describe 'validates uniqueness of keyword scoped to boosted content' do
    it { is_expected.to validate_uniqueness_of(:value).scoped_to(:boosted_content_id).case_insensitive }
  end

  it 'squishes value' do
    expect(boosted_contents(:basic).boosted_content_keywords.pluck(:value)).to eq(['barack obama'])
  end

  describe '#dup' do
    subject(:original_instance) { keyword }

    include_examples 'dupable',
                     %w(boosted_content_id)
  end
end
