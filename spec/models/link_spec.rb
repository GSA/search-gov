require 'spec_helper'

describe Link do
  it { is_expected.to validate_presence_of(:title) }
  it { is_expected.to validate_presence_of(:url) }
  it { is_expected.to validate_presence_of(:position) }

  context 'with a url without scheme' do
    it 'httpfys url' do
      link = described_class.create(position: 0, title: 'click me', url: 'search.gov')

      expect(link.url).to eq 'https://search.gov'
    end
  end

  context 'with a blank title and url' do
    it 'marks link for deletion' do
      link = described_class.create(position: 0, title: 'click me', url: 'search.gov')
      link.update(title: '', url: '')

      expect(link).to be_marked_for_destruction
    end
  end
end
