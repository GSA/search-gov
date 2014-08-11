require 'active_support/inflector'
class FuzzyMatcher
  def initialize(str1, str2)
    @str1, @str2 = str1, str2
  end

  def matches?
    normalize(@str1).eql?(normalize(@str2)) unless @str1.nil? or @str2.nil?
  end

  private
  def normalize(str)
    ActiveSupport::Inflector.transliterate(str)
  end

end