require 'spec_helper'

describe YoutubePlaylistsParser do
  describe '#playlist_ids' do
    it 'should return all available playlist ids' do
      playlists_feed_doc = File.read(Rails.root.to_s + '/spec/fixtures/rss/youtube_playlists.xml')
      next_playlists_feed_doc = File.read(Rails.root.to_s + '/spec/fixtures/rss/next_youtube_playlists.xml')
      Kernel.should_receive(:open).
          with(%r[^http://gdata.youtube.com/feeds/api/users/whitehouse/playlists\?alt=rss&max-results=50&start-index=]i).
          twice.
          and_return(playlists_feed_doc, next_playlists_feed_doc)

      parser = YoutubePlaylistsParser.new('whitehouse')
      playlist_ids = parser.playlist_ids
      playlist_ids.count.should == 52
      playlist_ids.first.should == 'PLRJNAhZxtqH9rgU-W1SqojlC27wSDg6jC'
      playlist_ids.last.should == 'PLE94EF18328AC72F3'
    end
  end
end