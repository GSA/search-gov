class FormSearch < WebSearch

  def initialize(options = {})
    super(options)
  end
  
  DEFAULT_SCOPE = "(form OR forms) (site:gov OR site:mil OR site:usps.com) (filetype:pdf OR contains:pdf)"

  protected

  def populate_additional_results(response)
  end
  
  def related_search_results
    []
  end

  def scope
    DEFAULT_SCOPE
  end
end
