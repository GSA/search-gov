module XmlProcessor
  def strip_comments(xml)
    doc = Nokogiri::HTML::DocumentFragment.parse xml
    doc.children.each { |c| strip_comments_on_node(c) }
    doc.to_html.strip
  end

  private
  def strip_comments_on_node(node)
    node.remove and return if node.comment?
    node.children.each do |c|
      strip_comments_on_node c
    end
  end
end