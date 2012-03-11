module QueryPreprocessor

  def preprocess(query)
    query.strip.gsub(/^"$/, '').gsub(/^[\+\-&\|]+/, '').gsub(/(AND|OR|NOT)\b/, '\\\\\1') unless query.blank?
  end
  module_function :preprocess
end
