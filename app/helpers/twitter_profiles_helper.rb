module TwitterProfilesHelper
  AUTO_LINK_RE = %r{
    (?: ((?:ed2k|ftp|http|https|irc|mailto|news|gopher|nntp|telnet|webcal|xmpp|callto|feed|svn|urn|aim|rsync|tag|ssh|sftp|rtsp|afs):)// | www\. )
    [^\s<]+
  }x
  BRACKETS = { ']' => '[', ')' => '(', '}' => '{' }
  WORD_PATTERN = '\p{Word}'

  # Copied from the rails_autolink gem; slightly simpler since we don't need to handle
  # redundant calls to `auto_link'
  def auto_link(tweet_text, query, index)
    tweet_text.gsub(AUTO_LINK_RE) do
      scheme, href = $1, $&
      punctuation = []

      # don't include trailing punctuation character as part of the URL
      while href.sub!(/[^#{WORD_PATTERN}\/-]$/, '')
        punctuation.push $&
        if opening = BRACKETS[punctuation.last] and href.scan(opening).size > href.scan(punctuation.last).size
          href << punctuation.pop
          break
        end
      end

      href = "http://#{href}" unless scheme

      tweet_link_with_click_tracking(truncate(href.gsub(/^#{scheme}\/\//, '').html_safe, :length => 20), href, @affiliate, query, index, @search_vertical) + punctuation.reverse.join('')
    end
  end

  def render_twitter_profile(profile, query, index)
    content = []
    content << profile.name
    content << content_tag(:span, " @#{profile.screen_name}", :class => 'screen-name')
    raw(tweet_link_with_click_tracking(content.join("\n").html_safe, profile.link_to_profile, @affiliate, query, index, @search_vertical))
  end
end
