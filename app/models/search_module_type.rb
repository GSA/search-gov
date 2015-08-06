class SearchModuleType
  MAPPING = { bbg: FeaturedCollection, boos: BoostedContent, qrtd: RoutedQuery }
  class << self
    def get_klass(module_tag)
      MAPPING[module_tag.downcase.to_sym]
    end
  end
end