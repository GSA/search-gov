module SitelinksHelper
  def sitelink_items(result, position)
    result['sitelinks'].collect do |link_hash|
      content_tag(:li) do
        link_to_sitelink link_hash[:title], link_hash[:url], position
      end
    end.join("\n").html_safe
  end
end
