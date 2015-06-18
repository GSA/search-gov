require 'spec_helper'

describe BoostedContentKeyword do
  fixtures :boosted_contents

  it { should validate_presence_of :value }
  it { should belong_to :boosted_content }
  it { should_not allow_value("piped|keywords").for(:value) }
  it { should_not allow_value("comma,separated,keywords").for(:value) }

  let!(:keyword) do
    boosted_contents(:basic).boosted_content_keywords.create!(value: '  barack   obama  ')
  end

  describe "validates uniqueness of keyword scoped to boosted content" do
    it { should validate_uniqueness_of(:value).scoped_to(:boosted_content_id) }
  end

  it 'squishes value' do
    boosted_contents(:basic).boosted_content_keywords.pluck(:value).should == ['barack obama']
  end

  describe '#dup' do
    subject(:original_instance) { keyword }

    include_examples 'dupable',
                     %w(boosted_content_id)
  end
end
