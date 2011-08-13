class SeedLogfileBlockedUserAgent < ActiveRecord::Migration
  def self.up
    bots = ["Googlebot", "Baiduspider", "DotBot", "crawler@evreka.com", "bitlybot", "CamontSpider", "CatchBot",
            "CCBot", "COMODOspider", "ConveraCrawler", "cyberpatrolcrawler", "CydralSpider", "DotSpotsBot",
            "Educational Crawler", "eventBot", "findfiles.net", "Gigabot", "sai-crawler.callingcard",
            "ia_archiver", "ICC-Crawler", "ICRA_Semantic_spider", "IssueCrawler", "Jbot", "KIT webcrawler",
            "KS Crawler", "KSCrawler", "Lijit", "Linguee Bot", "MLBot", "Kwaclebot", "80legs.com/spider.html",
            "ellerdale.com/crawler.html", "aiHitBot", "archive.org_bot", "cdlwas_bot", "discobot",
            "Dow Jones Searchbot", "Exabot", "Feedtrace-bot", "foobot", "accelobot.com", "MarketDefenderBot",
            "MJ12bot", "mxbot", "Purebot", "Reflectbot", "RssFetcherBot", "Search17Bot", "sgbot", "spbot",
            "Speedy Spider", "woriobot", "xalodotvn-crawler", "YioopBot", "Twiceler", "msnbot",
            "MSR-ISRCCrawler", "Netchart Adv Crawler", "NetinfoBot", "PicselSpider", "psbot",
            "R6_FeedFetcher", "radian6_linkcheck_", "SindiceBot", "Snapbot", "Sogou web spider",
            "Sosospider", "Speedy Spider", "Tasapspider", "the.cyrus.hellborg.sharecrawler",
            "TurnitinBot", "yacybot", "YaDirectBot", "Yeti", "compatible; ICS", "TVersity Media Robot",
            "Java/1.6.0_16", "Pingdom.com_bot", "YandexBot", "SiteScope", "Jakarta Commons-HttpClient"]
    bots.each { |bot| LogfileBlockedUserAgent.create(:agent => bot) }
  end

  def self.down
  end
end
