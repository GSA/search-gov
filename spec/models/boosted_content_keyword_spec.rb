require 'spec_helper'

describe BoostedContentKeyword do
  fixtures :boosted_contents

  it { should validate_presence_of :value }
  it { should belong_to :boosted_content }
  it { should_not allow_value("piped|keywords").for(:value) }
  it { should_not allow_value("comma,separated,keywords").for(:value) }

  describe "validates uniqueness of keyword scoped to boosted content" do
    before do
      boosted_contents(:basic).boosted_content_keywords.create!(:value => 'obama')
    end

    it { should validate_uniqueness_of(:value).scoped_to(:boosted_content_id) }
  end

  it 'squishes value' do
    boosted_contents(:basic).boosted_content_keywords.create!(:value => '  barack   obama  ')
    boosted_contents(:basic).boosted_content_keywords.pluck(:value).should == ['barack obama']
  end
end
