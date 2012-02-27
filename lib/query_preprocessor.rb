module QueryPreprocessor

  def preprocess(query)
    if query =~ /health it/ and !(query =~ /^\".*health it.*\"$/)
      sanitized_query = query.gsub(/health it/, '"health it"')
    else
      sanitized_query = query
    end
    sanitized_query.strip.gsub(/^"$/, '').gsub(/^[\+\-&\|]+/, '').gsub(/(AND|OR|NOT)\b/, '\\\\\1') unless sanitized_query.blank?
  end
  module_function :preprocess
end
