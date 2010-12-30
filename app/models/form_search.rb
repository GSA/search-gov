class FormSearch < Search

  DEFAULT_SCOPE = "(form OR forms) (site:gov OR site:mil OR site:usps.com) (filetype:pdf OR contains:pdf)"
  
  protected
  
  def related_search_results
    []
  end
  
  def populate_additional_results
  end
  
  def scope
    DEFAULT_SCOPE
  end
end