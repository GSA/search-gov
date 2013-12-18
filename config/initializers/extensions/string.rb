# coding: utf-8
class String
  NON_CAPITALIZED = %w{ a al an and ante as at bajo but by cabe con conmigo consigo contigo contra de del desde
      durante e el en entre et etc for from hacia hasta in into la las los mediante ni nor o of off on onto or out
      para pero por salvo según sin so sobre than the to tras u un una unas unos v versus via vs vía with y }

  def sentence_case
    gsub(/(\b|')[a-z]+/) { |w| NON_CAPITALIZED.include?(w) ? w : w.capitalize }.sub(/^[a-z]/) { |l| l.upcase }
  end

end
