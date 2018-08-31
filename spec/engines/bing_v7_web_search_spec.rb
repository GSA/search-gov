describe BingV7WebSearch do
  subject { described_class.new(options) }

  it_behaves_like 'a Bing search'
  it_behaves_like 'a web search engine'
end
