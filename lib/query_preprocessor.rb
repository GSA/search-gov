module QueryPreprocessor
  
  def preprocess(query)
    if query =~ /health it/ and !(query =~ /^\".*health it.*\"$/)
      query.gsub(/health it/, '"health it"')
    else
      query
    end
  end
  module_function :preprocess
end
