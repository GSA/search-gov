require 'spec_helper'

describe URI do
  describe '#self.merge_unless_recursive(self_url, target_url)?' do
    let(:self_url) { described_class.parse('http://www.foo.gov/rss-feeds/media-garbage') }
    context "when the target URL looks like it's going to create a relative self-reference" do
      let(:target_url) { described_class.parse('rss-feeds/media-garbage') }
      it 'should return nil' do
        expect(described_class.merge_unless_recursive(self_url, target_url)).to be_nil
      end
    end

    context 'when the target URL looks sane' do
      let(:target_url) { described_class.parse('/rss-feeds/media-garbage2') }
      it 'should return the merged URLs' do
        expect(described_class.merge_unless_recursive(self_url, target_url)).to eq(described_class.parse('http://www.foo.gov/rss-feeds/media-garbage2'))
      end
    end
  end

end
