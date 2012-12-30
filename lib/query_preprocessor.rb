module QueryPreprocessor

  def preprocess(query)
    query.squish.gsub(/^"$/, '').gsub(/^\{![^\}]+\}|^[\+\-&\|]+/, '').gsub(/(AND|OR|NOT)\b/, '\\\\\1') unless query.blank?
  end
  module_function :preprocess
end
