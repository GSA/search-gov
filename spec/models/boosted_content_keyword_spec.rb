require 'spec_helper'

describe BoostedContentKeyword do
  fixtures :boosted_contents

  it { should validate_presence_of :value }
  it { should belong_to :boosted_content }

  describe "validates uniqueness of keyword scoped to boosted content" do
    before do
      boosted_contents(:basic).boosted_content_keywords.create!(:value => 'obama')
    end

    it { should validate_uniqueness_of(:value).scoped_to(:boosted_content_id) }

  end
end