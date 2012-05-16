class String
  NON_CAPITALIZED = %w{ a al an and ante as at bajo but by cabe con conmigo consigo contigo contra de del desde
      durante e el en entre et etc for from hacia hasta in into la las los mediante ni nor o of off on onto or out
      para pero por salvo según sin so sobre than the to tras u un una unas unos v versus via vs vía with y }

  def fuzzily_matches?(str)
    gsub(/[\W]/, '').eql? str.gsub(/[\W]/, '') unless str.nil?
  end

  def sentence_case
    gsub(/(\b|')[a-z]+/) { |w| NON_CAPITALIZED.include?(w) ? w : w.capitalize }.sub(/^[a-z]/) { |l| l.upcase }
  end

  def longest_common_substring(s2)
    max, start = 0, 0
    self.length.times do |i|
      s2.length.times do |j|
        x = 0
        while self[i + x] == s2[j + x]
          x += 1
          break if (i + x) >= self.length or (j + x) >= s2.length
        end
        max, start = x, i if x > max
      end
    end
    self[start, max]
  end

end