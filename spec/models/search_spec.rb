require "#{File.dirname(__FILE__)}/../spec_helper"

describe Search do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:basic_affiliate)
    @valid_options = {:query => 'government', :page => 3, :affiliate => @affiliate }
  end

  describe "#run" do
    context "for every single request" do
      before do
        BoostedSite.stub!(:search_for).and_return(nil)
        uri = URI.parse(Search::JSON_SITE)
        @http = Net::HTTP.new(uri.host, uri.port)
        Net::HTTP.stub!(:new).and_return(@http)
        Net::HTTP::Get.stub!(:new).and_return({})
        @response = mock("response")
        body = "{\"SearchResponse\":{\"Version\":\"2.2\",\"Query\":{\"SearchTerms\":\"casa blanka (scopeid:usagovall OR site:.gov OR site:.mil)\",\"AlteredQuery\":\"casa blanca\",\"AlterationOverrideQuery\":\"casa +blanka (scopeid:usagovall | site:.gov | site:.mil)\"},\"Spell\":{\"Total\":1,\"Results\":[{\"Value\":\"some suggestion\"}]},\"Web\":{\"Total\":63800,\"Offset\":30,\"Results\":[{\"Title\":\"Search for Public Schools - School Detail for Casa Blanca Continuation\",\"Description\":\"Use the Search For Public Schools locator to retrieve information on all U.S. public schools. This data is collected annually directly from State Education Agencies (SEAs).\",\"Url\":\"http:\\/\\/nces.ed.gov\\/ccd\\/schoolsearch\\/school_detail.asp?Search=1&State=06&County=Fresno&SchoolPageNum=3&ID=061425001637\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=5014507496868489&w=f38308db,92535ccd\",\"DisplayUrl\":\"nces.ed.gov\\/ccd\\/schoolsearch\\/school_detail.asp?Search=1&State=06&County=Fresno&SchoolPage...\",\"DateTime\":\"2009-10-20T01:09:40Z\"},{\"Title\":\"Rana tarahumarae release at Big Casa Blanca Canyon 5\\/6\\/05\",\"Description\":\"Tarahumara Frog ( Rana tarahumarae ) Release, Monitoring, and Reconnaissance of Nearby Canyons Report: 11-13 October 2005 Rana tarahumarae release at Big Casa Blanca Canyon 5\\/6\\/05\",\"Url\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/Documents\\/SpeciesDocs\\/TarahumaraFrog\\/TFrog_monitoring_Oct05.pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4733230090095781&w=1f88ec0c,d9bf7d56\",\"DisplayUrl\":\"www.fws.gov\\/southwest\\/es\\/arizona\\/Documents\\/SpeciesDocs\\/TarahumaraFrog\\/TFrog_monitoring...\",\"DateTime\":\"2009-09-30T05:08:08Z\"},{\"Title\":\"The White House - Blog Post - Al ritmo de salsa, bachata y bamba en la ...\",\"Description\":\"La Fiesta Latina en la Casa Blanca fue parte de una serie de eventos musicales que se realizan desde el 1978 y la cual incluyó a principios de este año eventos de la música ...\",\"Url\":\"http:\\/\\/www.whitehouse.gov\\/blog\\/Al-ritmo-de-salsa-bachata-y-bamba-en-la-Casa-Blanca\\/\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=164988978537&w=65c50ed5,27fafdaa\",\"DisplayUrl\":\"www.whitehouse.gov\\/blog\\/Al-ritmo-de-salsa-bachata-y-bamba-en-la-Casa-Blanca\",\"DateTime\":\"2009-10-23T03:22:07Z\"},{\"Title\":\"Casa Blanca Rd\",\"Description\":\"E1_1A.dgn\",\"Url\":\"http:\\/\\/www.azdot.gov\\/highways\\/cms\\/edgncells\\/traffic_sign04\\/pdf\\/E1_1A.pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4802233032835510&w=bc8dbc5d,925e895\",\"DisplayUrl\":\"www.azdot.gov\\/highways\\/cms\\/edgncells\\/traffic_sign04\\/pdf\\/E1_1A.pdf\",\"DateTime\":\"2009-10-12T23:37:45Z\"},{\"Title\":\"CASA BLANCA MAN SENTENCED TO 7 ½ YEARS IN PRISON FOR AGGRAVATED ...\",\"Description\":\"Office of the United States Attorney District of Arizona FOR IMMEDIATE RELEASE For Information Contact Public Affairs Tuesday, August 12, 2008 SANDRA RAYNOR Telephone: (602) 514 ...\",\"Url\":\"http:\\/\\/www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-202(Manuel).pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4885787326876735&w=b638e66d,e33b99bb\",\"DisplayUrl\":\"www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-202(Manuel).pdf\",\"DateTime\":\"2009-10-15T17:14:48Z\"},{\"Title\":\"CASA BLANCA MAN SENTENCED TO OVER 6 YEARS IN PRISON FOR ROBBERY\",\"Description\":\"Office of the United States Attorney District of Arizona FOR IMMEDIATE RELEASE For Information Contact Public Affairs Tuesday, September 2, 2008 SANDY RAYNOR Telephone: (602) 514 ...\",\"Url\":\"http:\\/\\/www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-222(Renteria).pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4592655811478100&w=6b6680d2,b6cb5b67\",\"DisplayUrl\":\"www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-222(Renteria).pdf\",\"DateTime\":\"2009-10-16T01:43:03Z\"},{\"Title\":\"Tarahumara Frog Conservation Program\",\"Description\":\"All known populations of the Tarahumara frog have been extirpated from Arizona . The species was last seen in Gardner Canyon in 1977, Adobe Canyon in 1974, Big Casa Blanca Canyon ...\",\"Url\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4603779775332786&w=4fc329e5,7bed5f38\",\"DisplayUrl\":\"www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"DateTime\":\"2009-10-15T11:38:22Z\"},{\"Title\":\"Citrus Label Collection \\/ Casa Blanca Brand (2).jpg\",\"Description\":\"Citrus Label Collection\\/Casa Blanca Brand (2).jpg Previous | Home | Next\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/library\\/local-history\\/Citrus%20Labels\\/pages\\/Casa%20Blanca%20Brand%20(2)_jpg.htm\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4757440820153017&w=b0061191,94f5ac31\",\"DisplayUrl\":\"www.riversideca.gov\\/library\\/local-history\\/Citrus%20Labels\\/pages\\/Casa%20Blanca%20Brand%20...\",\"DateTime\":\"2009-10-16T07:05:10Z\"},{\"Title\":\"WhiteHouse.gov en Español\",\"Description\":\"Whitehouse.gov\\/spanish es el sitio web oficial de la Casa Blanca y el Presidente número 44 de los Estados Unidos, Barack Obama en español. Este sitio sirve fuente de información ...\",\"Url\":\"https:\\/\\/www.whitehouse.gov\\/espanol\\/\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4613344672876890&w=82c4c1ca,ab843bf\",\"DisplayUrl\":\"https:\\/\\/www.whitehouse.gov\\/espanol\",\"DateTime\":\"2009-10-19T21:56:24Z\"},{\"Title\":\"apps1.eere.energy.gov\",\"Description\":\"Statistics for CUB_Casa.Blanca_SWERA. Location -- CASA_BLANCA - CUB {N 23 10'} {W 82 20'} {GMT -5.0 Hours} Elevation -- 50m above sea level\",\"Url\":\"http:\\/\\/apps1.eere.energy.gov\\/buildings\\/energyplus\\/weatherdata\\/4_north_and_central_america_wmo_region_4\\/CUB_Casa.Blanca_SWERA.stat\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4574406494257510&w=4d9ce575,386c06fb\",\"DisplayUrl\":\"apps1.eere.energy.gov\\/...\\/4_north_and_central_america_wmo_region_4\\/CUB_Casa.Blanca_SWERA.stat\",\"DateTime\":\"2009-10-12T20:45:57Z\"}]},\"Image\":{\"Total\":507,\"Offset\":0,\"Results\":[{\"Title\":\"Casa Blanca, New Mexico\",\"MediaUrl\":\"http:\\/\\/tps.cr.nps.gov\\/nhl\\/nhl-images\\/NMAcomaview.jpg\",\"Url\":\"http:\\/\\/tps.cr.nps.gov\\/nhl\\/detail.cfm?ResourceId=357&ResourceType=District\",\"DisplayUrl\":\"http:\\/\\/tps.cr.nps.gov\\/nhl\\/detail.cfm?ResourceId=357&ResourceType=District\",\"Width\":249,\"Height\":162,\"FileSize\":19325,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1118030469326&id=2b1c65cd8f4967215a59de0b090cafd8\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":104,\"FileSize\":3208}},{\"Title\":\" ... casa blanca new mexico\",\"MediaUrl\":\"http:\\/\\/www.nps.gov\\/nero\\/nhlphoto\\/2008HM_01_lg.jpg\",\"Url\":\"http:\\/\\/www.nps.gov\\/nero\\/nhlphoto\\/2008honorablementions.htm\",\"DisplayUrl\":\"http:\\/\\/www.nps.gov\\/nero\\/nhlphoto\\/2008honorablementions.htm\",\"Width\":233,\"Height\":350,\"FileSize\":67937,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1210914710213&id=8b7a5d4ccaf07b78db8dbe49680673d8\",\"ContentType\":\"image\\/jpeg\",\"Width\":106,\"Height\":160,\"FileSize\":4103}},{\"Title\":\"Casa Blanca Library & Family ... \",\"MediaUrl\":\"http:\\/\\/www.riversideca.gov\\/library\\/images\\/casablanca_dedication274.jpg\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/library\\/loc_casablanca.asp\",\"DisplayUrl\":\"http:\\/\\/www.riversideca.gov\\/library\\/loc_casablanca.asp\",\"Width\":274,\"Height\":170,\"FileSize\":68583,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1281896223355&id=d4653d39d528c23641a88c3f62bbca6c\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":99,\"FileSize\":3570}},{\"Title\":\"Bienvenidos a la Casa Blanca ... \",\"MediaUrl\":\"http:\\/\\/www.usar.army.mil\\/arweb\\/organization\\/commandstructure\\/USARC\\/OPS\\/200MP\\/News\\/PublishingImages\\/Guerra\\/Guerra%20featured.jpg\",\"Url\":\"http:\\/\\/www.usar.army.mil\\/arweb\\/organization\\/commandstructure\\/USARC\\/OPS\\/200MP\",\"DisplayUrl\":\"http:\\/\\/www.usar.army.mil\\/arweb\\/organization\\/commandstructure\\/USARC\\/OPS\\/200MP\",\"Width\":287,\"Height\":197,\"FileSize\":49065,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1221382376236&id=724069caad9e42a8cdcae11ab4148cab\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":109,\"FileSize\":4549}},{\"Title\":\"Casa Blanca Redevelopment ... \",\"MediaUrl\":\"http:\\/\\/www.riversideca.gov\\/redev\\/images\\/maps\\/casablanca.gif\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/redev\\/project-areas-casablanca.asp\",\"DisplayUrl\":\"http:\\/\\/www.riversideca.gov\\/redev\\/project-areas-casablanca.asp\",\"Width\":500,\"Height\":389,\"FileSize\":26360,\"ContentType\":\"image\\/gif\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1112895000036&id=9afa09db4330ea48b363440dddd01e02\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":124,\"FileSize\":4279}},{\"Title\":\" ... in Big Casa Blanca Canyon\",\"MediaUrl\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/images\\/SpeciesImages\\/JRorabaugh\\/TfrogBgCsa.gif\",\"Url\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"DisplayUrl\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"Width\":318,\"Height\":486,\"FileSize\":144093,\"ContentType\":\"image\\/gif\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1229868967581&id=602c1519b2b95561b1da00143f4cdc07\",\"ContentType\":\"image\\/jpeg\",\"Width\":104,\"Height\":160,\"FileSize\":4218}},{\"Title\":\"Casa Blanca Neighborhood\",\"MediaUrl\":\"http:\\/\\/www.riversideca.gov\\/neighborhoods\\/images\\/nhw2-6.jpg\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/neighborhoods\\/neighborhoods-casa-blanca.asp\",\"DisplayUrl\":\"http:\\/\\/www.riversideca.gov\\/neighborhoods\\/neighborhoods-casa-blanca.asp\",\"Width\":190,\"Height\":142,\"FileSize\":19259,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1229485122062&id=effbd1805c65bc2280ec6babe64504aa\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":119,\"FileSize\":5366}},{\"Title\":\" ... sitio web de la Casa Blanca\",\"MediaUrl\":\"http:\\/\\/photos.state.gov\\/libraries\\/amgov\\/3234\\/week_4\\/052909-whitehouse-200.jpg\",\"Url\":\"http:\\/\\/www.america.gov\\/st\\/usg-spanish\\/2009\\/June\\/20090602110924emanym0.5557825.html\",\"DisplayUrl\":\"http:\\/\\/www.america.gov\\/st\\/usg-spanish\\/2009\\/June\\/20090602110924emanym0.5557825.html\",\"Width\":200,\"Height\":135,\"FileSize\":8515,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1055196716427&id=eb246d3bcd1ce453241fa5da0d804221\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":108,\"FileSize\":4340}},{\"Title\":\" de la Casa Blanca ... \",\"MediaUrl\":\"http:\\/\\/www.globalliteracy.gov\\/2006\\/images\\/spanish\\/header_sp.jpg\",\"Url\":\"http:\\/\\/www.globalliteracy.gov\\/2006\\/spanish\\/\",\"DisplayUrl\":\"http:\\/\\/www.globalliteracy.gov\\/2006\\/spanish\\/\",\"Width\":605,\"Height\":135,\"FileSize\":66627,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1059456289978&id=d6f15e0dc79717ed15267c8375197b49\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":35,\"FileSize\":1915}},{\"Title\":\" Bush en la Casa Blanca ... \",\"MediaUrl\":\"http:\\/\\/www.usembassy-mexico.gov\\/scrapbook\\/web_quality\\/hispanic_month\\/wq_hispanic_031002.jpg\",\"Url\":\"http:\\/\\/www.usembassy-mexico.gov\\/boletines\\/sp031002hispa_month.htm\",\"DisplayUrl\":\"http:\\/\\/www.usembassy-mexico.gov\\/boletines\\/sp031002hispa_month.htm\",\"Width\":320,\"Height\":240,\"FileSize\":23459,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1152248913848&id=99f5aeae3b008b9fb010ea19c8ee7aad\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":120,\"FileSize\":4607}}]},\"RelatedSearch\":{\"Results\":[{\"Title\":\"Casablanca Movie\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casablanca+Movie\"},{\"Title\":\"Casablanca\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casablanca\"},{\"Title\":\"Casa Blanca Mesquite NV\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casa+Blanca+Mesquite+NV\"},{\"Title\":\"Casa Blanca Golf Resort\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casa+Blanca+Golf+Resort\"},{\"Title\":\"Casa Blanca Fans\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casa+Blanca+Fans\"}]}}}"
        @response.stub!(:body).and_return(body)
      end

      it "should send Client-IP and User-Agent in request to Bing" do
        @http.should_receive(:request).with({"Client-IP"=>"209.251.180.16", "User-Agent"=>"USASearch"}).and_return(@response)
        Search.new(@valid_options).run
      end
    end

    context "when JSON cannot be parsed for some reason" do
      before do
        JSON.should_receive(:parse).once.and_raise(JSON::ParserError)
        @search = Search.new(@valid_options)
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

      it "should log a warning" do
        RAILS_DEFAULT_LOGGER.should_receive(:warn)
        @search.run
      end
    end

    context "when a SocketError occurs" do
      before do
        @search = Search.new(@valid_options)
        Net::HTTP::Get.stub!(:new).and_raise SocketError
      end

      it "should return false when searching" do
        @search.run.should be_false
      end
    end

    context "when Bing gives us the hand" do
      before do
        @search = Search.new(@valid_options)
        Net::HTTP::Get.stub!(:new).and_raise Errno::ECONNREFUSED
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

    end

    context "when Bing kicks us to the curb" do
      before do
        @search = Search.new(@valid_options)
        Net::HTTP::Get.stub!(:new).and_raise Errno::ECONNRESET
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

    end

    context "when Bing takes waaaaaaaaay to long to respond" do
      before do
        @search = Search.new(@valid_options)
        Net::HTTP::Get.stub!(:new).and_raise Timeout::Error
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

    end

    context "when Bing is unreachable" do
      before do
        @search = Search.new(@valid_options)
        Net::HTTP::Get.stub!(:new).and_raise Errno::ENETUNREACH
      end

      it "should return false when searching" do
        @search.run.should be_false
      end
    end

    context "when non-English locale is specified" do
      before do
        I18n.locale = :es
      end

      it "should pass a language filter to Bing" do
        uriresult = URI::parse("http://localhost:3000/")
        search = Search.new(@valid_options)
        URI.should_receive(:parse).with(/%20language%3Aes/).and_return(uriresult)
        search.run
      end

      it "should not search for Spotlights, GovForms or FAQs" do
        search = Search.new(@valid_options.merge(:affiliate => nil))
        Spotlight.should_not_receive(:search_for)
        GovForm.should_not_receive(:search_for)
        Faq.should_not_receive(:search_for)
        search.run
      end

      after do
        I18n.locale = I18n.default_locale
      end
    end

    context "when affiliate has domains specified and user does not specify site: in search" do
      it "should use affiliate domains in query to Bing without passing ScopeID" do
        affiliate = Affiliate.new(:domains => %w(foo.com bar.com).join("\n"))
        uriresult = URI::parse("http://localhost:3000/")
        search = Search.new(@valid_options.merge(:affiliate => affiliate))
        URI.should_receive(:parse).with(/query=\(government\)%20\(site%3Afoo\.com%20OR%20site%3Abar\.com\)$/).and_return(uriresult)
        search.run
      end
    end

    context "when affiliate has domains specified but user specifies site: in search" do
      it "should override affiliate domains in query to Bing and use ScopeID/gov/mil combo" do
        affiliate = Affiliate.new(:domains => %w(foo.com bar.com).join("\n"))
        uriresult = URI::parse("http://localhost:3000/")
        search = Search.new(@valid_options.merge(:affiliate => affiliate, :query=>"government site:blat.gov"))
        URI.should_receive(:parse).with(/query=\(government%20site%3Ablat\.gov\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)$/).and_return(uriresult)
        search.run
      end
    end

    context "when affiliate has no domains specified" do
      it "should use just query string and ScopeID/gov/mil combo" do
        uriresult = URI::parse("http://localhost:3000/")
        search = Search.new(@valid_options.merge(:affiliate => Affiliate.new))
        URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)$/).and_return(uriresult)
        search.run
      end
    end

    context "when affiliate is nil" do
      before do
        @search = Search.new(@valid_options.merge(:affiliate => nil))
      end

      it "should use just query string and ScopeID/gov/mil combo" do
        uriresult = URI::parse("http://localhost:3000/")
        URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)$/).and_return(uriresult)
        @search.run
      end

      it "should search for FAQs" do
        Faq.should_receive(:search_for).with('government')
        @search.run
      end

      it "should search for GovForms" do
        GovForm.should_receive(:search_for).with('government')
        @search.run
      end
    end

    context "when affiliate is not nil" do
      it "should not search for FAQs" do
        search = Search.new(@valid_options)
        Faq.should_not_receive(:search_for)
        search.run
      end

      it "should not search for GovForms" do
        search = Search.new(@valid_options)
        GovForm.should_not_receive(:search_for)
        search.run
      end
    end

    context "when page offset is specified" do
      it "should specify the offset in the query to Bing" do
        uriresult = URI::parse("http://localhost:3000/")
        search = Search.new(@valid_options.merge(:page => 7))
        URI.should_receive(:parse).with(/web\.offset=70/).and_return(uriresult)
        search.run
      end
    end

    context "when advanced query parameters are passed" do
      before do
        @uriresult = URI::parse('http://localhost:3000')
      end

      context "when query is limited to search only in titles" do
        it "should construct a query string with the intitle: limits on the query parameter" do
          search = Search.new(@valid_options.merge(:query_limit => "intitle:"))
          URI.should_receive(:parse).with(/query=\(intitle%3Agovernment\)/).and_return(@uriresult)
          search.run
        end

        context "when more than one query term is specified" do
          it "should construct a query string with intitle: limits before each query term" do
            search = Search.new(@valid_options.merge(:query => 'barack obama', :query_limit => 'intitle:'))
            URI.should_receive(:parse).with(/query=\(intitle%3Abarack%20intitle%3Aobama\)/).and_return(@uriresult)
            search.run
          end
        end

        context "when query limit is blank" do
          it "should not use the query limit in the query string" do
            search = Search.new(@valid_options.merge(:query_limit => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when a phrase query is specified" do
        it "should construct a query string that includes the phrase in quotes" do
          search = Search.new(@valid_options.merge(:query_quote => 'barack obama'))
          URI.should_receive(:parse).with(/%22barack%20obama%22/).and_return(@uriresult)
          search.run
        end

        context "when the phrase query limit is set to intitle:" do
          it "should construct a query string with the intitle: limit on the phrase query" do
            search = Search.new(@valid_options.merge(:query_quote => 'barack obama', :query_quote_limit => 'intitle:'))
            URI.should_receive(:parse).with(/%20intitle%3A%22barack%20obama%22/).and_return(@uriresult)
            search.run
          end
        end

        context "and it is blank" do
          it "should not include a phrase query in the url" do
            search = Search.new(@valid_options.merge(:query_quote => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end

        context "when the phrase query is blank and the phrase query limit is blank" do
          it "should not include anything relating to phrase query in the query string" do
            search = Search.new(@valid_options.merge(:query_quote => '', :query_quote_limit => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when OR terms are specified" do
        it "should construct a query string that includes the OR terms OR'ed together" do
          search = Search.new(@valid_options.merge(:query_or => 'barack obama'))
          URI.should_receive(:parse).with(/barack%20OR%20obama/).and_return(@uriresult)
          search.run
        end

        context "when the OR query limit is set to intitle:" do
          it "should construct a query string that includes the OR terms with intitle prefix" do
            search = Search.new(@valid_options.merge(:query_or => 'barack obama', :query_or_limit => 'intitle:'))
            URI.should_receive(:parse).with(/intitle%3Abarack%20OR%20intitle%3Aobama/).and_return(@uriresult)
            search.run
          end
        end

        context "when the OR query is blank" do
          it "should not include an OR query parameter in the query string" do
            search = Search.new(@valid_options.merge(:query_or => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end

        context "when the OR query is blank and the OR query limit is blank" do
          it "should not include anything relating to OR query in the query string" do
            search = Search.new(@valid_options.merge(:query_or => '', :query_or_limit => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when negative query terms are specified" do
        it "should construct a query string that includes the negative query terms prefixed with '-'" do
          search = Search.new(@valid_options.merge(:query_not => 'barack obama'))
          URI.should_receive(:parse).with(/-barack%20-obama/).and_return(@uriresult)
          search.run
        end

        context "when the negative query limit is set to intitle:" do
          it "should construct a query string that includes the negative terms with intitle prefix" do
            search = Search.new(@valid_options.merge(:query_not => 'barack obama', :query_not_limit => 'intitle:'))
            URI.should_receive(:parse).with(/-intitle%3Abarack%20-intitle%3Aobama/).and_return(@uriresult)
            search.run
          end
        end

        context "when the negative query is blank" do
          it "should not include a negative query parameter in the query string" do
            search = Search.new(@valid_options.merge(:query_not => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end

        context "when the negative query is blank and the negative query limit are blank" do
          it "should not include anything relating to negative query in the query string" do
            search = Search.new(@valid_options.merge(:query_not => '', :query_not_limit => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when a filetype is specified" do
        it "should construct a query string that includes a filetype" do
          search = Search.new(@valid_options.merge(:file_type => 'pdf'))
          URI.should_receive(:parse).with(/filetype%3Apdf/).and_return(@uriresult)
          search.run
        end

        context "when the filetype specified is 'All'" do
          it "should construct a query string that does not have a filetype parameter" do
            search = Search.new(@valid_options.merge(:file_type => 'All'))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end

        context "when a blank filetype is passed in" do
          it "should not put filetype parameters in the query string" do
            search = Search.new(@valid_options.merge(:file_type => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when one or more site limits are specified" do
        it "should construct a query string with site limits for each of the sites" do
          search = Search.new(@valid_options.merge(:site_limits => 'whitehouse.gov omb.gov'))
          URI.should_receive(:parse).with(/site%3Awhitehouse.gov%20OR%20site%3Aomb.gov/).and_return(@uriresult)
          search.run
        end

        context "when a blank site limit is passed" do
          it "should not include site limit in the query string" do
            search = Search.new(@valid_options.merge(:site_limits => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when one or more site exclusions is specified" do
        it "should construct a query string with site exlcusions for each of the sites" do
          search = Search.new(@valid_options.merge(:site_excludes => "whitehouse.gov omb.gov"))
          URI.should_receive(:parse).with(/-site%3Awhitehouse.gov%20-site%3Aomb.gov/).and_return(@uriresult)
          search.run
        end

        context "when a blank site exclude is passed" do
          it "should not include site exclude in the query string" do
            search = Search.new(@valid_options.merge(:site_excludes => ''))
            URI.should_receive(:parse).with(/query=\(government\)%20\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when a fedstates parameter is specified" do
        it "should set the scope if with the fedstates parameter" do
          search = Search.new(@valid_options.merge(:fedstates => 'MD'))
          URI.should_receive(:parse).with(/\(scopeid%3AusagovMD\)/).and_return(@uriresult)
          search.run
        end

        context "when the fedstates parameter specified is 'all'" do
          it "should use the 'usagovall' scopeid with .gov and .mil sites included" do
            search = Search.new(@valid_options.merge(:fedstates => 'all'))
            URI.should_receive(:parse).with(/\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end

        context "when fedstates parameter is blank" do
          it "should use the 'usagovall' scope id with .gov and .mil sites included" do
            search = Search.new(@valid_options.merge(:fedstates => ''))
            URI.should_receive(:parse).with(/\(scopeid%3Ausagovall%20OR%20site%3Agov%20OR%20site%3Amil\)/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when a results per page number is specified" do
        it "should construct a query string with the appropriate per page variable set" do
          search = Search.new(@valid_options.merge(:results_per_page => 20))
          URI.should_receive(:parse).with(/web\.count=20/).and_return(@uriresult)
          search.run
        end

        it "should not set a per page value above 50" do
          search = Search.new(@valid_options.merge(:results_per_page => 100))
          URI.should_receive(:parse).with(/web\.count=50/).and_return(@uriresult)
          search.run
        end

        context "when the results_per_page variable passed is blank" do
          it "should set the per-page parameter to the default value, defined by the DEFAULT_PER_PAGE variable" do
            search = Search.new(@valid_options)
            URI.should_receive(:parse).with(/web\.count=10/).and_return(@uriresult)
            search.run
          end
        end

        context "when the results_per_page variable that is passed is a string" do
          it "should convert the string to an integer and not fail" do
            search = Search.new(@valid_options.merge(:results_per_page => "30"))
            URI.should_receive(:parse).with(/web\.count=30/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when multiple or all of the advanced query parameters are specified" do
        it "should construct a query string that incorporates all of them with the proper spacing" do
          search = Search.new(@valid_options.merge(:query_limit => 'intitle:',
                                                   :query_quote => 'barack obama',
                                                   :query_quote_limit => '',
                                                   :query_or => 'cars stimulus',
                                                   :query_or_limit => '',
                                                   :query_not => 'clunkers',
                                                   :query_not_limit => 'intitle:',
                                                   :file_type => 'pdf',
                                                   :site_limits => 'whitehouse.gov omb.gov',
                                                   :site_excludes => 'nasa.gov noaa.gov'))
          URI.should_receive(:parse).with(/query=\(intitle%3Agovernment%20%22barack%20obama%22%20cars%20OR%20stimulus%20-intitle%3Aclunkers%20filetype%3Apdf%20site%3Awhitehouse.gov%20OR%20site%3Aomb.gov%20-site%3Anasa.gov%20-site%3Anoaa.gov\)/).and_return(@uriresult)
          search.run
        end
      end

      context "when a filter parameter is set" do
        it "should set the Adult parameter in the query sent to Bing" do
          search = Search.new(@valid_options.merge(:filter => 'moderate'))
          URI.should_receive(:parse).with(/Adult=moderate/).and_return(@uriresult)
          search.run
        end

        context "when the filter parameter is blank" do
          it "should set the Adult parameter to the default value ('strict')" do
            search = Search.new(@valid_options.merge(:filter => ''))
            URI.should_receive(:parse).with(/Adult=strict/).and_return(@uriresult)
            search.run
          end
        end
      end

      context "when a filter parameter is not set" do
        it "should set the Adult parameter to the default value ('strict')" do
          search = Search.new(@valid_options)
          URI.should_receive(:parse).with(/Adult=strict/).and_return(@uriresult)
          search.run
        end
      end

    end

    context "when searching with valid queries" do
      before do
        @search = Search.new(@valid_options)
        @search.run
      end

      it "should find results based on query" do
        @search.results.size.should > 0
      end

      it "should have a total at least as large as the first set of results" do
        @search.total.should >= @search.results.size
      end

      it "should have a related searches array" do
        @search.related_search.size.should > 0
        @search.related_search.first.title.should_not be_nil
        @search.related_search.first.url.should_not be_nil
      end

    end

    context "when the query contains an '&' character" do
      it "should pass a url-escaped query string to Bing" do
        @uriresult = URI::parse('http://localhost:3000')
        query = "Pros & Cons Physician Assisted Suicide"
        search = Search.new(@valid_options.merge(:query => query))
        URI.should_receive(:parse).with(/Pros%20%26%20Cons%20Physician%20Assisted%20Suicide/).and_return(@uriresult)
        search.run
      end
    end

    context "when search results contain related searches" do

      it "should filter block words from related searches" do
        BlockWord.should_receive(:filter).once
        @search = Search.new(@valid_options)
        @search.run
      end

    end

    context "when searching with really long queries" do
      before do
        @search = Search.new(@valid_options.merge(:query => "X"*10000))
      end

      it "should return false when searching" do
        @search.run.should be_false
      end

      it "should have 0 results" do
        @search.run
        @search.results.size.should == 0
      end

      it "should set error message" do
        @search.run
        @search.error_message.should_not be_nil
      end
    end

    context "when searching with nonsense queries" do
      before do
        @search = Search.new(@valid_options.merge(:query => 'kjdfgkljdhfgkldjshfglkjdsfhg'))
      end

      it "should return true when searching" do
        @search.run.should be_true
      end

      it "should have 0 results" do
        @search.run
        @search.results.size.should == 0
      end
    end

    context "when results contain listing missing a title" do
      before do
        @search = Search.new(@valid_options.merge(:query => 'Nas & Kelis'))
        json = File.read(RAILS_ROOT + "/spec/fixtures/json/bing_two_search_results_one_missing_title.json")
        parsed = JSON.parse(json)
        JSON.stub!(:parse).and_return parsed
      end

      it "should ignore that result" do
        @search.run
        @search.results.size.should == 1
      end
    end

    context "when results contain listing missing a description" do
      before do
        @search = Search.new(@valid_options.merge(:query => 'data'))
        json = File.read(RAILS_ROOT + "/spec/fixtures/json/bing_search_results_with_some_missing_descriptions.json")
        parsed = JSON.parse(json)
        JSON.stub!(:parse).and_return parsed
      end

      it "should use a blank description" do
        @search.run
        @search.results.size.should == 10
        @search.results.each do |result|
          result['content'].should == ""
        end
      end
    end

    context "when searching for misspelled terms" do
      before do
        @search = Search.new(@valid_options.merge(:query => "o'bama"))
        @search.run
      end

      it "should have spelling suggestions" do
        @search.spelling_suggestion.should == "obama"
      end
    end

    context "when suggestions for misspelled terms contain scope parameters" do
      before do
        @search = Search.new(@valid_options.merge(:query => 'data.org'))
        @search.run
      end

      it "should strip them all out" do
        @search.spelling_suggestion.should_not match(/scopeid:/)
        @search.spelling_suggestion.should_not match(/site:/)
      end
    end

    context "spotlight searches" do
      fixtures :spotlights
      context "when a spotlight is set up for something relevant to the search term" do
        before do
          @spotty = spotlights(:time)
        end

        it "should assign the Spotlight" do
          @search = Search.new(@valid_options.merge(:query => 'walk time', :affiliate=> nil))
          Spotlight.should_receive(:search_for).with('walk time').and_return(@spotty)
          @search.run
          @search.spotlight.should == @spotty
        end
      end

      context "when no relevant spotlight exists for the search term" do
        it "should assign a nil Spotlight" do
          @search = Search.new(@valid_options.merge(:query => 'nothing here', :affiliate=> nil))
          Spotlight.should_receive(:search_for).with('nothing here').and_return(nil)
          @search.run
          @search.spotlight.should be_nil
        end
      end
    end

    context "recent recalls (last month)" do
      before do
        @date_filter_hash= {:start_date=>1.month.ago.to_date, :end_date=>Date.today}
      end

      context "when search term does not contain recall or recalls" do
        it "should not look for recalls" do
          search = Search.new(@valid_options.merge(:query => 'foo bar'))
          Recall.should_not_receive(:search_for)
          search.run
        end
      end

      context "when search phrase is just the word recall(s)" do
        it "should not look for recalls" do
          search = Search.new(@valid_options.merge(:query => 'recall'))
          Recall.should_not_receive(:search_for)
          search.run
        end
      end

      context "when search phrase contains recall" do
        it "should strip off the recall word before searching" do
          search = Search.new(@valid_options.merge(:query => 'foo bar recall'))
          Recall.should_receive(:search_for).with('foo bar', @date_filter_hash)
          search.run
        end
      end

      context "when search phrase contains recalls" do
        it "should strip off the recalls word before searching" do
          search = Search.new(@valid_options.merge(:query => 'recalls of pepper'))
          Recall.should_receive(:search_for).with('of pepper', @date_filter_hash)
          search.run
        end
      end

      context "when no relevant recall exists for the search term" do
        it "should assign nil to recalls" do
          search = Search.new(@valid_options.merge(:query => 'nothing here recall'))
          Recall.should_receive(:search_for).with('nothing here', @date_filter_hash).and_return(nil)
          search.run
          search.recalls.should be_nil
        end
      end

      context "when search phrase stripped of 'recall' is an unparseable query string" do
        it "should catch an rsolr error and assign nil to recalls" do
          search = Search.new(@valid_options.merge(:query => 'sheetrock OR recall'))
          Recall.should_receive(:search_for).with('sheetrock OR', @date_filter_hash).and_raise(RSolr::RequestError)
          search.run
          search.recalls.should be_nil
        end
      end
    end

    context "when paginating" do
      default_page = 0

      it "should default to page 0 if no valid page number was specified" do
        options_without_page = @valid_options.reject{|k, v| k == :page}
        Search.new(options_without_page).page.should == default_page
        Search.new(@valid_options.merge(:page => '')).page.should == default_page
        Search.new(@valid_options.merge(:page => 'string')).page.should == default_page
      end

      it "should set the page number" do
        search = Search.new(@valid_options.merge(:page => 2))
        search.page.should == 2
      end

      it "should use the underlying engine's results per page" do
        search = Search.new(@valid_options)
        search.run
        search.results.size.should == Search::DEFAULT_PER_PAGE
      end

      it "should set startrecord/endrecord" do
        page = 7
        search = Search.new(@valid_options.merge(:page => page))
        search.run
        search.startrecord.should == Search::DEFAULT_PER_PAGE * page + 1
        search.endrecord.should == search.startrecord + search.results.size - 1
      end
    end
  end

  describe "when new" do
    it "should have a settable query" do
      search = Search.new(@valid_options)
      search.query.should == 'government'
    end

    it "should have a settable affiliate" do
      search = Search.new(@valid_options)
      search.affiliate.should == @affiliate
    end

    it "should not require a query or affiliate" do
      lambda { Search.new }.should_not raise_error(ArgumentError)
    end
  end

  describe "#suggestions()" do
    before do
      phrase = "aaaazy"
      16.times { SaytSuggestion.create!(:phrase => phrase.succ!) }
    end

    it "should default to returning 15 suggestions" do
      Search.suggestions("aaa").size.should == 15
    end

    it "should accept an override for number of suggestions to return" do
      Search.suggestions("aaa", 6).size.should == 6
    end

    it "should return suggestions in alphabetical order" do
      suggs = Search.suggestions("aaa")
      suggs.first.phrase.should == "aaaazz"
      suggs.last.phrase.should == "aaaban"
    end

    context "when no suggestions exist for the query" do
      before do
        SaytSuggestion.create!(:phrase => "affiliate")
      end

      it "should guess at a suggestion by iteratively removing the last letter of the query and retrying" do
        Search.suggestions("affilaite").first.phrase.should == "affiliate"              
      end
    end
  end

  describe "#hits(response)" do
    context "when Bing reports a total > 0 but gives no results whatsoever" do
      before do
        @search = Search.new
        @response = mock("response")
        web = mock("web")
        @response.stub!(:web).and_return(web)
        web.stub!(:results).and_return(nil)
        web.stub!(:total).and_return(4000)
      end

      it "should return zero for the number of hits" do
        @search.send(:hits, @response).should == 0
      end
    end
  end
end
