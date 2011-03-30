module Enumerable
  def custom_uniq_by(& block)
    uniq = {}
    each_with_index do |val, idx|
      key = block.call(val)
      uniq[key] = [idx, val]
    end
    values = uniq.values
    values.sort! { |a, b| a.first <=> b.first }
    values.map! { |pair| pair.last }
    values
  end
end