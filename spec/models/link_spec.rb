require 'spec_helper'

RSpec.describe Link, type: :model do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_presence_of(:position) }

  context 'with a url without scheme' do
    it 'httpfys url' do
      link = Link.create(position: 0, title: 'click me', url: 'search.gov')

      expect(link.url).to eq 'https://search.gov'
    end
  end
end
