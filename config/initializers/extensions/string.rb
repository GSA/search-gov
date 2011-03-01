class String
  def fuzzily_matches?(str)
    self.gsub(/[\W]/, '').eql? str.gsub(/[\W]/, '') unless str.nil?
  end
end