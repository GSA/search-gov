describe BingV6ImageSearch do
  subject(:search) { described_class.new(options) }

  it_behaves_like 'a Bing search'
  it_behaves_like 'an image search'
end
