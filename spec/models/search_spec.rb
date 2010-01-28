require "#{File.dirname(__FILE__)}/../spec_helper"

describe Search do
  fixtures :affiliates

  before do
    @affiliate = affiliates(:basic_affiliate)
    @valid_options = {:query => 'government', :page => 3, :affiliate => @affiliate}
  end

  describe "#run" do
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

    context "when non-English locale is specified" do
      before do
        I18n.locale = :es
      end

      it "should pass a language filter to Bing" do
        uriresult = URI::parse("http://localhost:3000/")
        search = Search.new(@valid_options)
        URI.should_receive(:parse).with(/%20language:es/).and_return(uriresult)
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
        URI.should_receive(:parse).with(/query=government%20\(site:foo\.com%20OR%20site:bar\.com\)$/).and_return(uriresult)
        search.run
      end
    end

    context "when affiliate has domains specified but user specifies site: in search" do
      it "should override affiliate domains in query to Bing and use ScopeID/gov/mil combo" do
        affiliate = Affiliate.new(:domains => %w(foo.com bar.com).join("\n"))
        uriresult = URI::parse("http://localhost:3000/")
        search = Search.new(@valid_options.merge(:affiliate => affiliate, :query=>"government site:blat.gov"))
        URI.should_receive(:parse).with(/query=government%20site:blat\.gov%20\(scopeid:usagovall%20OR%20site:\.gov%20OR%20site:\.mil\)$/).and_return(uriresult)
        search.run
      end
    end

    context "when affiliate has no domains specified" do
      it "should use just query string and ScopeID/gov/mil combo" do
        uriresult = URI::parse("http://localhost:3000/")
        search = Search.new(@valid_options.merge(:affiliate => Affiliate.new))
        URI.should_receive(:parse).with(/query=government%20\(scopeid:usagovall%20OR%20site:\.gov%20OR%20site:\.mil\)$/).and_return(uriresult)
        search.run
      end
    end

    context "when affiliate is nil" do
      it "should use just query string and ScopeID/gov/mil combo" do
        uriresult = URI::parse("http://localhost:3000/")
        search = Search.new(@valid_options.merge(:affiliate => nil))
        URI.should_receive(:parse).with(/query=government%20\(scopeid:usagovall%20OR%20site:\.gov%20OR%20site:\.mil\)$/).and_return(uriresult)
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

    context "when searching with 'adult' queries" do
      before do
        @search = Search.new(@valid_options.merge(:query => 'clitoris'))
      end

      it "should return true when searching" do
        @search.run.should be_true
      end

      it "should have 0 results" do
        @search.run
        @search.results.size.should == 0
      end
    end

    context "when searching for misspelled terms" do
      before do
        @search = Search.new(@valid_options.merge(:query => 'casa blanka'))
        response = mock("response")
        Net::HTTP.should_receive(:get_response).and_return(response)
        body = "{\"SearchResponse\":{\"Version\":\"2.2\",\"Query\":{\"SearchTerms\":\"casa blanka (scopeid:usagovall OR site:.gov OR site:.mil)\",\"AlteredQuery\":\"casa blanca\",\"AlterationOverrideQuery\":\"casa +blanka (scopeid:usagovall | site:.gov | site:.mil)\"},\"Spell\":{\"Total\":1,\"Results\":[{\"Value\":\"some suggestion\"}]},\"Web\":{\"Total\":63800,\"Offset\":30,\"Results\":[{\"Title\":\"Search for Public Schools - School Detail for Casa Blanca Continuation\",\"Description\":\"Use the Search For Public Schools locator to retrieve information on all U.S. public schools. This data is collected annually directly from State Education Agencies (SEAs).\",\"Url\":\"http:\\/\\/nces.ed.gov\\/ccd\\/schoolsearch\\/school_detail.asp?Search=1&State=06&County=Fresno&SchoolPageNum=3&ID=061425001637\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=5014507496868489&w=f38308db,92535ccd\",\"DisplayUrl\":\"nces.ed.gov\\/ccd\\/schoolsearch\\/school_detail.asp?Search=1&State=06&County=Fresno&SchoolPage...\",\"DateTime\":\"2009-10-20T01:09:40Z\"},{\"Title\":\"Rana tarahumarae release at Big Casa Blanca Canyon 5\\/6\\/05\",\"Description\":\"Tarahumara Frog ( Rana tarahumarae ) Release, Monitoring, and Reconnaissance of Nearby Canyons Report: 11-13 October 2005 Rana tarahumarae release at Big Casa Blanca Canyon 5\\/6\\/05\",\"Url\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/Documents\\/SpeciesDocs\\/TarahumaraFrog\\/TFrog_monitoring_Oct05.pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4733230090095781&w=1f88ec0c,d9bf7d56\",\"DisplayUrl\":\"www.fws.gov\\/southwest\\/es\\/arizona\\/Documents\\/SpeciesDocs\\/TarahumaraFrog\\/TFrog_monitoring...\",\"DateTime\":\"2009-09-30T05:08:08Z\"},{\"Title\":\"The White House - Blog Post - Al ritmo de salsa, bachata y bamba en la ...\",\"Description\":\"La Fiesta Latina en la Casa Blanca fue parte de una serie de eventos musicales que se realizan desde el 1978 y la cual incluyó a principios de este año eventos de la música ...\",\"Url\":\"http:\\/\\/www.whitehouse.gov\\/blog\\/Al-ritmo-de-salsa-bachata-y-bamba-en-la-Casa-Blanca\\/\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=164988978537&w=65c50ed5,27fafdaa\",\"DisplayUrl\":\"www.whitehouse.gov\\/blog\\/Al-ritmo-de-salsa-bachata-y-bamba-en-la-Casa-Blanca\",\"DateTime\":\"2009-10-23T03:22:07Z\"},{\"Title\":\"Casa Blanca Rd\",\"Description\":\"E1_1A.dgn\",\"Url\":\"http:\\/\\/www.azdot.gov\\/highways\\/cms\\/edgncells\\/traffic_sign04\\/pdf\\/E1_1A.pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4802233032835510&w=bc8dbc5d,925e895\",\"DisplayUrl\":\"www.azdot.gov\\/highways\\/cms\\/edgncells\\/traffic_sign04\\/pdf\\/E1_1A.pdf\",\"DateTime\":\"2009-10-12T23:37:45Z\"},{\"Title\":\"CASA BLANCA MAN SENTENCED TO 7 ½ YEARS IN PRISON FOR AGGRAVATED ...\",\"Description\":\"Office of the United States Attorney District of Arizona FOR IMMEDIATE RELEASE For Information Contact Public Affairs Tuesday, August 12, 2008 SANDRA RAYNOR Telephone: (602) 514 ...\",\"Url\":\"http:\\/\\/www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-202(Manuel).pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4885787326876735&w=b638e66d,e33b99bb\",\"DisplayUrl\":\"www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-202(Manuel).pdf\",\"DateTime\":\"2009-10-15T17:14:48Z\"},{\"Title\":\"CASA BLANCA MAN SENTENCED TO OVER 6 YEARS IN PRISON FOR ROBBERY\",\"Description\":\"Office of the United States Attorney District of Arizona FOR IMMEDIATE RELEASE For Information Contact Public Affairs Tuesday, September 2, 2008 SANDY RAYNOR Telephone: (602) 514 ...\",\"Url\":\"http:\\/\\/www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-222(Renteria).pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4592655811478100&w=6b6680d2,b6cb5b67\",\"DisplayUrl\":\"www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-222(Renteria).pdf\",\"DateTime\":\"2009-10-16T01:43:03Z\"},{\"Title\":\"Tarahumara Frog Conservation Program\",\"Description\":\"All known populations of the Tarahumara frog have been extirpated from Arizona . The species was last seen in Gardner Canyon in 1977, Adobe Canyon in 1974, Big Casa Blanca Canyon ...\",\"Url\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4603779775332786&w=4fc329e5,7bed5f38\",\"DisplayUrl\":\"www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"DateTime\":\"2009-10-15T11:38:22Z\"},{\"Title\":\"Citrus Label Collection \\/ Casa Blanca Brand (2).jpg\",\"Description\":\"Citrus Label Collection\\/Casa Blanca Brand (2).jpg Previous | Home | Next\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/library\\/local-history\\/Citrus%20Labels\\/pages\\/Casa%20Blanca%20Brand%20(2)_jpg.htm\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4757440820153017&w=b0061191,94f5ac31\",\"DisplayUrl\":\"www.riversideca.gov\\/library\\/local-history\\/Citrus%20Labels\\/pages\\/Casa%20Blanca%20Brand%20...\",\"DateTime\":\"2009-10-16T07:05:10Z\"},{\"Title\":\"WhiteHouse.gov en Español\",\"Description\":\"Whitehouse.gov\\/spanish es el sitio web oficial de la Casa Blanca y el Presidente número 44 de los Estados Unidos, Barack Obama en español. Este sitio sirve fuente de información ...\",\"Url\":\"https:\\/\\/www.whitehouse.gov\\/espanol\\/\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4613344672876890&w=82c4c1ca,ab843bf\",\"DisplayUrl\":\"https:\\/\\/www.whitehouse.gov\\/espanol\",\"DateTime\":\"2009-10-19T21:56:24Z\"},{\"Title\":\"apps1.eere.energy.gov\",\"Description\":\"Statistics for CUB_Casa.Blanca_SWERA. Location -- CASA_BLANCA - CUB {N 23 10'} {W 82 20'} {GMT -5.0 Hours} Elevation -- 50m above sea level\",\"Url\":\"http:\\/\\/apps1.eere.energy.gov\\/buildings\\/energyplus\\/weatherdata\\/4_north_and_central_america_wmo_region_4\\/CUB_Casa.Blanca_SWERA.stat\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4574406494257510&w=4d9ce575,386c06fb\",\"DisplayUrl\":\"apps1.eere.energy.gov\\/...\\/4_north_and_central_america_wmo_region_4\\/CUB_Casa.Blanca_SWERA.stat\",\"DateTime\":\"2009-10-12T20:45:57Z\"}]},\"Image\":{\"Total\":507,\"Offset\":0,\"Results\":[{\"Title\":\"Casa Blanca, New Mexico\",\"MediaUrl\":\"http:\\/\\/tps.cr.nps.gov\\/nhl\\/nhl-images\\/NMAcomaview.jpg\",\"Url\":\"http:\\/\\/tps.cr.nps.gov\\/nhl\\/detail.cfm?ResourceId=357&ResourceType=District\",\"DisplayUrl\":\"http:\\/\\/tps.cr.nps.gov\\/nhl\\/detail.cfm?ResourceId=357&ResourceType=District\",\"Width\":249,\"Height\":162,\"FileSize\":19325,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1118030469326&id=2b1c65cd8f4967215a59de0b090cafd8\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":104,\"FileSize\":3208}},{\"Title\":\" ... casa blanca new mexico\",\"MediaUrl\":\"http:\\/\\/www.nps.gov\\/nero\\/nhlphoto\\/2008HM_01_lg.jpg\",\"Url\":\"http:\\/\\/www.nps.gov\\/nero\\/nhlphoto\\/2008honorablementions.htm\",\"DisplayUrl\":\"http:\\/\\/www.nps.gov\\/nero\\/nhlphoto\\/2008honorablementions.htm\",\"Width\":233,\"Height\":350,\"FileSize\":67937,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1210914710213&id=8b7a5d4ccaf07b78db8dbe49680673d8\",\"ContentType\":\"image\\/jpeg\",\"Width\":106,\"Height\":160,\"FileSize\":4103}},{\"Title\":\"Casa Blanca Library & Family ... \",\"MediaUrl\":\"http:\\/\\/www.riversideca.gov\\/library\\/images\\/casablanca_dedication274.jpg\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/library\\/loc_casablanca.asp\",\"DisplayUrl\":\"http:\\/\\/www.riversideca.gov\\/library\\/loc_casablanca.asp\",\"Width\":274,\"Height\":170,\"FileSize\":68583,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1281896223355&id=d4653d39d528c23641a88c3f62bbca6c\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":99,\"FileSize\":3570}},{\"Title\":\"Bienvenidos a la Casa Blanca ... \",\"MediaUrl\":\"http:\\/\\/www.usar.army.mil\\/arweb\\/organization\\/commandstructure\\/USARC\\/OPS\\/200MP\\/News\\/PublishingImages\\/Guerra\\/Guerra%20featured.jpg\",\"Url\":\"http:\\/\\/www.usar.army.mil\\/arweb\\/organization\\/commandstructure\\/USARC\\/OPS\\/200MP\",\"DisplayUrl\":\"http:\\/\\/www.usar.army.mil\\/arweb\\/organization\\/commandstructure\\/USARC\\/OPS\\/200MP\",\"Width\":287,\"Height\":197,\"FileSize\":49065,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1221382376236&id=724069caad9e42a8cdcae11ab4148cab\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":109,\"FileSize\":4549}},{\"Title\":\"Casa Blanca Redevelopment ... \",\"MediaUrl\":\"http:\\/\\/www.riversideca.gov\\/redev\\/images\\/maps\\/casablanca.gif\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/redev\\/project-areas-casablanca.asp\",\"DisplayUrl\":\"http:\\/\\/www.riversideca.gov\\/redev\\/project-areas-casablanca.asp\",\"Width\":500,\"Height\":389,\"FileSize\":26360,\"ContentType\":\"image\\/gif\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1112895000036&id=9afa09db4330ea48b363440dddd01e02\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":124,\"FileSize\":4279}},{\"Title\":\" ... in Big Casa Blanca Canyon\",\"MediaUrl\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/images\\/SpeciesImages\\/JRorabaugh\\/TfrogBgCsa.gif\",\"Url\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"DisplayUrl\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"Width\":318,\"Height\":486,\"FileSize\":144093,\"ContentType\":\"image\\/gif\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1229868967581&id=602c1519b2b95561b1da00143f4cdc07\",\"ContentType\":\"image\\/jpeg\",\"Width\":104,\"Height\":160,\"FileSize\":4218}},{\"Title\":\"Casa Blanca Neighborhood\",\"MediaUrl\":\"http:\\/\\/www.riversideca.gov\\/neighborhoods\\/images\\/nhw2-6.jpg\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/neighborhoods\\/neighborhoods-casa-blanca.asp\",\"DisplayUrl\":\"http:\\/\\/www.riversideca.gov\\/neighborhoods\\/neighborhoods-casa-blanca.asp\",\"Width\":190,\"Height\":142,\"FileSize\":19259,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1229485122062&id=effbd1805c65bc2280ec6babe64504aa\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":119,\"FileSize\":5366}},{\"Title\":\" ... sitio web de la Casa Blanca\",\"MediaUrl\":\"http:\\/\\/photos.state.gov\\/libraries\\/amgov\\/3234\\/week_4\\/052909-whitehouse-200.jpg\",\"Url\":\"http:\\/\\/www.america.gov\\/st\\/usg-spanish\\/2009\\/June\\/20090602110924emanym0.5557825.html\",\"DisplayUrl\":\"http:\\/\\/www.america.gov\\/st\\/usg-spanish\\/2009\\/June\\/20090602110924emanym0.5557825.html\",\"Width\":200,\"Height\":135,\"FileSize\":8515,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1055196716427&id=eb246d3bcd1ce453241fa5da0d804221\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":108,\"FileSize\":4340}},{\"Title\":\" de la Casa Blanca ... \",\"MediaUrl\":\"http:\\/\\/www.globalliteracy.gov\\/2006\\/images\\/spanish\\/header_sp.jpg\",\"Url\":\"http:\\/\\/www.globalliteracy.gov\\/2006\\/spanish\\/\",\"DisplayUrl\":\"http:\\/\\/www.globalliteracy.gov\\/2006\\/spanish\\/\",\"Width\":605,\"Height\":135,\"FileSize\":66627,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1059456289978&id=d6f15e0dc79717ed15267c8375197b49\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":35,\"FileSize\":1915}},{\"Title\":\" Bush en la Casa Blanca ... \",\"MediaUrl\":\"http:\\/\\/www.usembassy-mexico.gov\\/scrapbook\\/web_quality\\/hispanic_month\\/wq_hispanic_031002.jpg\",\"Url\":\"http:\\/\\/www.usembassy-mexico.gov\\/boletines\\/sp031002hispa_month.htm\",\"DisplayUrl\":\"http:\\/\\/www.usembassy-mexico.gov\\/boletines\\/sp031002hispa_month.htm\",\"Width\":320,\"Height\":240,\"FileSize\":23459,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1152248913848&id=99f5aeae3b008b9fb010ea19c8ee7aad\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":120,\"FileSize\":4607}}]},\"RelatedSearch\":{\"Results\":[{\"Title\":\"Casablanca Movie\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casablanca+Movie\"},{\"Title\":\"Casablanca\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casablanca\"},{\"Title\":\"Casa Blanca Mesquite NV\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casa+Blanca+Mesquite+NV\"},{\"Title\":\"Casa Blanca Golf Resort\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casa+Blanca+Golf+Resort\"},{\"Title\":\"Casa Blanca Fans\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casa+Blanca+Fans\"}]}}}"
        response.should_receive(:body).and_return(body)
        @search.run
      end

      it "should have spelling suggestions" do
        @search.spelling_suggestion.should == "some suggestion"
      end
    end

    context "when suggestions for misspelled terms contain scope parameters and highlighting" do
      before do
        @search = Search.new(@valid_options.merge(:query => 'data.org'))
        response = mock("response")
        Net::HTTP.should_receive(:get_response).and_return(response)
        body = "{\"SearchResponse\":{\"Version\":\"2.2\",\"Query\":{\"SearchTerms\":\"data.org (scopeid:usagovall OR site:.gov OR site:.mil)\",\"AlteredQuery\":\"casa blanca\",\"AlterationOverrideQuery\":\"casa +blanka (scopeid:usagovall | site:.gov | site:.mil)\"},\"Spell\":{\"Total\":1,\"Results\":[{\"Value\":\"<strong>data.bg</strong> (scopeid:usagovall | site:.gov | site:.mil)\"}]},\"Web\":{\"Total\":63800,\"Offset\":30,\"Results\":[{\"Title\":\"Search for Public Schools - School Detail for Casa Blanca Continuation\",\"Description\":\"Use the Search For Public Schools locator to retrieve information on all U.S. public schools. This data is collected annually directly from State Education Agencies (SEAs).\",\"Url\":\"http:\\/\\/nces.ed.gov\\/ccd\\/schoolsearch\\/school_detail.asp?Search=1&State=06&County=Fresno&SchoolPageNum=3&ID=061425001637\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=5014507496868489&w=f38308db,92535ccd\",\"DisplayUrl\":\"nces.ed.gov\\/ccd\\/schoolsearch\\/school_detail.asp?Search=1&State=06&County=Fresno&SchoolPage...\",\"DateTime\":\"2009-10-20T01:09:40Z\"},{\"Title\":\"Rana tarahumarae release at Big Casa Blanca Canyon 5\\/6\\/05\",\"Description\":\"Tarahumara Frog ( Rana tarahumarae ) Release, Monitoring, and Reconnaissance of Nearby Canyons Report: 11-13 October 2005 Rana tarahumarae release at Big Casa Blanca Canyon 5\\/6\\/05\",\"Url\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/Documents\\/SpeciesDocs\\/TarahumaraFrog\\/TFrog_monitoring_Oct05.pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4733230090095781&w=1f88ec0c,d9bf7d56\",\"DisplayUrl\":\"www.fws.gov\\/southwest\\/es\\/arizona\\/Documents\\/SpeciesDocs\\/TarahumaraFrog\\/TFrog_monitoring...\",\"DateTime\":\"2009-09-30T05:08:08Z\"},{\"Title\":\"The White House - Blog Post - Al ritmo de salsa, bachata y bamba en la ...\",\"Description\":\"La Fiesta Latina en la Casa Blanca fue parte de una serie de eventos musicales que se realizan desde el 1978 y la cual incluyó a principios de este año eventos de la música ...\",\"Url\":\"http:\\/\\/www.whitehouse.gov\\/blog\\/Al-ritmo-de-salsa-bachata-y-bamba-en-la-Casa-Blanca\\/\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=164988978537&w=65c50ed5,27fafdaa\",\"DisplayUrl\":\"www.whitehouse.gov\\/blog\\/Al-ritmo-de-salsa-bachata-y-bamba-en-la-Casa-Blanca\",\"DateTime\":\"2009-10-23T03:22:07Z\"},{\"Title\":\"Casa Blanca Rd\",\"Description\":\"E1_1A.dgn\",\"Url\":\"http:\\/\\/www.azdot.gov\\/highways\\/cms\\/edgncells\\/traffic_sign04\\/pdf\\/E1_1A.pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4802233032835510&w=bc8dbc5d,925e895\",\"DisplayUrl\":\"www.azdot.gov\\/highways\\/cms\\/edgncells\\/traffic_sign04\\/pdf\\/E1_1A.pdf\",\"DateTime\":\"2009-10-12T23:37:45Z\"},{\"Title\":\"CASA BLANCA MAN SENTENCED TO 7 ½ YEARS IN PRISON FOR AGGRAVATED ...\",\"Description\":\"Office of the United States Attorney District of Arizona FOR IMMEDIATE RELEASE For Information Contact Public Affairs Tuesday, August 12, 2008 SANDRA RAYNOR Telephone: (602) 514 ...\",\"Url\":\"http:\\/\\/www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-202(Manuel).pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4885787326876735&w=b638e66d,e33b99bb\",\"DisplayUrl\":\"www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-202(Manuel).pdf\",\"DateTime\":\"2009-10-15T17:14:48Z\"},{\"Title\":\"CASA BLANCA MAN SENTENCED TO OVER 6 YEARS IN PRISON FOR ROBBERY\",\"Description\":\"Office of the United States Attorney District of Arizona FOR IMMEDIATE RELEASE For Information Contact Public Affairs Tuesday, September 2, 2008 SANDY RAYNOR Telephone: (602) 514 ...\",\"Url\":\"http:\\/\\/www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-222(Renteria).pdf\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4592655811478100&w=6b6680d2,b6cb5b67\",\"DisplayUrl\":\"www.usdoj.gov\\/usao\\/az\\/press_releases\\/2008\\/2008-222(Renteria).pdf\",\"DateTime\":\"2009-10-16T01:43:03Z\"},{\"Title\":\"Tarahumara Frog Conservation Program\",\"Description\":\"All known populations of the Tarahumara frog have been extirpated from Arizona . The species was last seen in Gardner Canyon in 1977, Adobe Canyon in 1974, Big Casa Blanca Canyon ...\",\"Url\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4603779775332786&w=4fc329e5,7bed5f38\",\"DisplayUrl\":\"www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"DateTime\":\"2009-10-15T11:38:22Z\"},{\"Title\":\"Citrus Label Collection \\/ Casa Blanca Brand (2).jpg\",\"Description\":\"Citrus Label Collection\\/Casa Blanca Brand (2).jpg Previous | Home | Next\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/library\\/local-history\\/Citrus%20Labels\\/pages\\/Casa%20Blanca%20Brand%20(2)_jpg.htm\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4757440820153017&w=b0061191,94f5ac31\",\"DisplayUrl\":\"www.riversideca.gov\\/library\\/local-history\\/Citrus%20Labels\\/pages\\/Casa%20Blanca%20Brand%20...\",\"DateTime\":\"2009-10-16T07:05:10Z\"},{\"Title\":\"WhiteHouse.gov en Español\",\"Description\":\"Whitehouse.gov\\/spanish es el sitio web oficial de la Casa Blanca y el Presidente número 44 de los Estados Unidos, Barack Obama en español. Este sitio sirve fuente de información ...\",\"Url\":\"https:\\/\\/www.whitehouse.gov\\/espanol\\/\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4613344672876890&w=82c4c1ca,ab843bf\",\"DisplayUrl\":\"https:\\/\\/www.whitehouse.gov\\/espanol\",\"DateTime\":\"2009-10-19T21:56:24Z\"},{\"Title\":\"apps1.eere.energy.gov\",\"Description\":\"Statistics for CUB_Casa.Blanca_SWERA. Location -- CASA_BLANCA - CUB {N 23 10'} {W 82 20'} {GMT -5.0 Hours} Elevation -- 50m above sea level\",\"Url\":\"http:\\/\\/apps1.eere.energy.gov\\/buildings\\/energyplus\\/weatherdata\\/4_north_and_central_america_wmo_region_4\\/CUB_Casa.Blanca_SWERA.stat\",\"CacheUrl\":\"http:\\/\\/cc.bingj.com\\/cache.aspx?q=casa+blanka&d=4574406494257510&w=4d9ce575,386c06fb\",\"DisplayUrl\":\"apps1.eere.energy.gov\\/...\\/4_north_and_central_america_wmo_region_4\\/CUB_Casa.Blanca_SWERA.stat\",\"DateTime\":\"2009-10-12T20:45:57Z\"}]},\"Image\":{\"Total\":507,\"Offset\":0,\"Results\":[{\"Title\":\"Casa Blanca, New Mexico\",\"MediaUrl\":\"http:\\/\\/tps.cr.nps.gov\\/nhl\\/nhl-images\\/NMAcomaview.jpg\",\"Url\":\"http:\\/\\/tps.cr.nps.gov\\/nhl\\/detail.cfm?ResourceId=357&ResourceType=District\",\"DisplayUrl\":\"http:\\/\\/tps.cr.nps.gov\\/nhl\\/detail.cfm?ResourceId=357&ResourceType=District\",\"Width\":249,\"Height\":162,\"FileSize\":19325,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1118030469326&id=2b1c65cd8f4967215a59de0b090cafd8\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":104,\"FileSize\":3208}},{\"Title\":\" ... casa blanca new mexico\",\"MediaUrl\":\"http:\\/\\/www.nps.gov\\/nero\\/nhlphoto\\/2008HM_01_lg.jpg\",\"Url\":\"http:\\/\\/www.nps.gov\\/nero\\/nhlphoto\\/2008honorablementions.htm\",\"DisplayUrl\":\"http:\\/\\/www.nps.gov\\/nero\\/nhlphoto\\/2008honorablementions.htm\",\"Width\":233,\"Height\":350,\"FileSize\":67937,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1210914710213&id=8b7a5d4ccaf07b78db8dbe49680673d8\",\"ContentType\":\"image\\/jpeg\",\"Width\":106,\"Height\":160,\"FileSize\":4103}},{\"Title\":\"Casa Blanca Library & Family ... \",\"MediaUrl\":\"http:\\/\\/www.riversideca.gov\\/library\\/images\\/casablanca_dedication274.jpg\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/library\\/loc_casablanca.asp\",\"DisplayUrl\":\"http:\\/\\/www.riversideca.gov\\/library\\/loc_casablanca.asp\",\"Width\":274,\"Height\":170,\"FileSize\":68583,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1281896223355&id=d4653d39d528c23641a88c3f62bbca6c\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":99,\"FileSize\":3570}},{\"Title\":\"Bienvenidos a la Casa Blanca ... \",\"MediaUrl\":\"http:\\/\\/www.usar.army.mil\\/arweb\\/organization\\/commandstructure\\/USARC\\/OPS\\/200MP\\/News\\/PublishingImages\\/Guerra\\/Guerra%20featured.jpg\",\"Url\":\"http:\\/\\/www.usar.army.mil\\/arweb\\/organization\\/commandstructure\\/USARC\\/OPS\\/200MP\",\"DisplayUrl\":\"http:\\/\\/www.usar.army.mil\\/arweb\\/organization\\/commandstructure\\/USARC\\/OPS\\/200MP\",\"Width\":287,\"Height\":197,\"FileSize\":49065,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1221382376236&id=724069caad9e42a8cdcae11ab4148cab\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":109,\"FileSize\":4549}},{\"Title\":\"Casa Blanca Redevelopment ... \",\"MediaUrl\":\"http:\\/\\/www.riversideca.gov\\/redev\\/images\\/maps\\/casablanca.gif\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/redev\\/project-areas-casablanca.asp\",\"DisplayUrl\":\"http:\\/\\/www.riversideca.gov\\/redev\\/project-areas-casablanca.asp\",\"Width\":500,\"Height\":389,\"FileSize\":26360,\"ContentType\":\"image\\/gif\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1112895000036&id=9afa09db4330ea48b363440dddd01e02\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":124,\"FileSize\":4279}},{\"Title\":\" ... in Big Casa Blanca Canyon\",\"MediaUrl\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/images\\/SpeciesImages\\/JRorabaugh\\/TfrogBgCsa.gif\",\"Url\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"DisplayUrl\":\"http:\\/\\/www.fws.gov\\/southwest\\/es\\/arizona\\/T_Frog.htm\",\"Width\":318,\"Height\":486,\"FileSize\":144093,\"ContentType\":\"image\\/gif\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1229868967581&id=602c1519b2b95561b1da00143f4cdc07\",\"ContentType\":\"image\\/jpeg\",\"Width\":104,\"Height\":160,\"FileSize\":4218}},{\"Title\":\"Casa Blanca Neighborhood\",\"MediaUrl\":\"http:\\/\\/www.riversideca.gov\\/neighborhoods\\/images\\/nhw2-6.jpg\",\"Url\":\"http:\\/\\/www.riversideca.gov\\/neighborhoods\\/neighborhoods-casa-blanca.asp\",\"DisplayUrl\":\"http:\\/\\/www.riversideca.gov\\/neighborhoods\\/neighborhoods-casa-blanca.asp\",\"Width\":190,\"Height\":142,\"FileSize\":19259,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1229485122062&id=effbd1805c65bc2280ec6babe64504aa\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":119,\"FileSize\":5366}},{\"Title\":\" ... sitio web de la Casa Blanca\",\"MediaUrl\":\"http:\\/\\/photos.state.gov\\/libraries\\/amgov\\/3234\\/week_4\\/052909-whitehouse-200.jpg\",\"Url\":\"http:\\/\\/www.america.gov\\/st\\/usg-spanish\\/2009\\/June\\/20090602110924emanym0.5557825.html\",\"DisplayUrl\":\"http:\\/\\/www.america.gov\\/st\\/usg-spanish\\/2009\\/June\\/20090602110924emanym0.5557825.html\",\"Width\":200,\"Height\":135,\"FileSize\":8515,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1055196716427&id=eb246d3bcd1ce453241fa5da0d804221\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":108,\"FileSize\":4340}},{\"Title\":\" de la Casa Blanca ... \",\"MediaUrl\":\"http:\\/\\/www.globalliteracy.gov\\/2006\\/images\\/spanish\\/header_sp.jpg\",\"Url\":\"http:\\/\\/www.globalliteracy.gov\\/2006\\/spanish\\/\",\"DisplayUrl\":\"http:\\/\\/www.globalliteracy.gov\\/2006\\/spanish\\/\",\"Width\":605,\"Height\":135,\"FileSize\":66627,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1059456289978&id=d6f15e0dc79717ed15267c8375197b49\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":35,\"FileSize\":1915}},{\"Title\":\" Bush en la Casa Blanca ... \",\"MediaUrl\":\"http:\\/\\/www.usembassy-mexico.gov\\/scrapbook\\/web_quality\\/hispanic_month\\/wq_hispanic_031002.jpg\",\"Url\":\"http:\\/\\/www.usembassy-mexico.gov\\/boletines\\/sp031002hispa_month.htm\",\"DisplayUrl\":\"http:\\/\\/www.usembassy-mexico.gov\\/boletines\\/sp031002hispa_month.htm\",\"Width\":320,\"Height\":240,\"FileSize\":23459,\"ContentType\":\"image\\/jpeg\",\"Thumbnail\":{\"Url\":\"http:\\/\\/ts1.mm.bing.net\\/images\\/thumbnail.aspx?q=1152248913848&id=99f5aeae3b008b9fb010ea19c8ee7aad\",\"ContentType\":\"image\\/jpeg\",\"Width\":160,\"Height\":120,\"FileSize\":4607}}]},\"RelatedSearch\":{\"Results\":[{\"Title\":\"Casablanca Movie\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casablanca+Movie\"},{\"Title\":\"Casablanca\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casablanca\"},{\"Title\":\"Casa Blanca Mesquite NV\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casa+Blanca+Mesquite+NV\"},{\"Title\":\"Casa Blanca Golf Resort\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casa+Blanca+Golf+Resort\"},{\"Title\":\"Casa Blanca Fans\",\"Url\":\"http:\\/\\/www.bing.com\\/search?q=Casa+Blanca+Fans\"}]}}}"
        response.should_receive(:body).and_return(body)
        @search.run
      end

      it "should strip them all out" do
        @search.spelling_suggestion.should == "data.bg"
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

end
