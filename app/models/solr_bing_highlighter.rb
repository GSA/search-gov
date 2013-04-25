class SolrBingHighlighter
  def self.hl(hit, field_symbol)
    return hit.highlights(field_symbol).first.format { |phrase| "\uE000#{phrase}\uE001" } unless hit.highlights(field_symbol).first.nil?
    hit.instance.send(field_symbol)
  end
end