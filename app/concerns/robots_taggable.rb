module RobotsTaggable
  def noindex?
    robots_directives.include?('none') || robots_directives.include?('noindex')
  end
end
